#!/root/.nvm/versions/node/v24.16.0/bin/node
/**
 * Hook 脚本：记录最近 5 轮对话到历史文件
 * 兼容 Linux / macOS，无需额外依赖（仅需 Node.js 内置模块）
 *
 * 通过 stdin 接收 Hook 输入的 JSON 对象
 */

const fs = require('fs');
const path = require('path');

const MAX_LINES = 500;
const MAX_ROUNDS = 5;

function readStdin() {
  return new Promise((resolve, reject) => {
    let data = '';
    process.stdin.setEncoding('utf8');
    process.stdin.on('data', chunk => { data += chunk; });
    process.stdin.on('end', () => resolve(data));
    process.stdin.on('error', reject);
  });
}

/**
 * 从 transcript JSONL 中提取最近 N 条 user 消息
 */
function extractUserMessages(lines, maxRounds) {
  const users = [];
  for (const line of lines) {
    if (!line.trim()) continue;
    try {
      const entry = JSON.parse(line);
      if (entry.type === 'user' && typeof entry.message?.content === 'string') {
        users.push({
          uuid: entry.uuid,
          ts: entry.timestamp,
          content: entry.message.content,
        });
      }
    } catch {
      // 跳过无效行
    }
  }
  return users.slice(-maxRounds);
}

/**
 * 解析 UTC 时间戳为本地时间字符串（跨平台，不依赖系统 date 命令）
 */
function formatTimestamp(ts) {
  if (!ts) return '';
  try {
    const d = new Date(ts);
    const pad = n => String(n).padStart(2, '0');
    return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())} ${pad(d.getHours())}:${pad(d.getMinutes())}:${pad(d.getSeconds())}`;
  } catch {
    return ts;
  }
}

/**
 * 收集今天所有历史文件中已有的 UUID
 */
function collectExistingUuids(historyDir, date) {
  const uuids = new Set();
  const files = fs.readdirSync(historyDir).filter(f => f.startsWith(`history-${date}`) && f.endsWith('.md'));
  const uuidRegex = /^\[uuid:([^\]]+)\]/;
  for (const file of files) {
    const content = fs.readFileSync(path.join(historyDir, file), 'utf8');
    for (const line of content.split('\n')) {
      const match = line.match(uuidRegex);
      if (match) uuids.add(match[1]);
    }
  }
  return uuids;
}

/**
 * 生成单条对话记录的 markdown 内容
 */
function buildRecord(userUuid, userTs, userContent, assistantContent) {
  const beijingTime = formatTimestamp(userTs);
  let text = `[uuid:${userUuid}]\n\n`;
  if (beijingTime) {
    text += `*${beijingTime}*\n\n`;
  }
  text += `**用户**: ${userContent}\n\n`;
  text += `**Claude**: ${assistantContent}\n\n`;
  text += `---\n\n`;
  return text;
}

/**
 * 找到合适的目标文件
 * 优先写入最后一个未满 500 行的文件，否则创建下一个编号文件
 */
function findTargetFile(historyDir, date) {
  const files = fs.readdirSync(historyDir).filter(f => {
    if (!f.startsWith(`history-${date}`) || !f.endsWith('.md')) return false;
    // 排除 -N.md 以外的（只取编号文件）
    const rest = f.slice(`history-${date}`.length); // 可能是 .md 或 -N.md
    if (rest === '.md') return true;
    return /^-\d+\.md$/.test(rest);
  }).sort();

  // 按编号顺序查找最后一个有空间的
  const sorted = [...files].sort((a, b) => {
    const numA = a === `history-${date}.md` ? 0 : parseInt(a.match(/-(\d+)\.md/)[1]);
    const numB = b === `history-${date}.md` ? 0 : parseInt(b.match(/-(\d+)\.md/)[1]);
    return numA - numB;
  });

  let lastWithRoom = null;
  let maxNum = 0;

  for (const file of sorted) {
    const filePath = path.join(historyDir, file);
    const lineCount = fs.readFileSync(filePath, 'utf8').split('\n').length;
    if (file === `history-${date}.md`) {
      maxNum = 0;
    } else {
      const m = file.match(/-(\d+)\.md/);
      if (m) maxNum = Math.max(maxNum, parseInt(m[1]));
    }
    if (lineCount < MAX_LINES) {
      lastWithRoom = filePath;
    }
  }

  if (lastWithRoom) return lastWithRoom;
  return path.join(historyDir, `history-${date}-${maxNum + 1}.md`);
}

/**
 * 确保文件有 markdown header
 */
function ensureHeader(filePath, date) {
  if (fs.existsSync(filePath)) return;
  const dateFormatted = `${date.slice(0, 4)}/${date.slice(4, 6)}/${date.slice(6, 8)}`;
  fs.writeFileSync(filePath, `# 对话记录 - ${dateFormatted}\n\n`, 'utf8');
}

/**
 * 找到项目根目录（包含 .claude 目录的父目录）
 */
function findProjectRoot() {
  let dir = process.cwd();
  while (dir !== '/') {
    const candidate = path.join(dir, '.claude');
    if (fs.existsSync(candidate) && fs.statSync(candidate).isDirectory()) {
      return dir;
    }
    dir = path.dirname(dir);
  }
  // 回退到当前目录
  return process.cwd();
}

/**
 * 获取当前 git 用户名（用于多人协作时区分历史文件）
 */
function getGitUsername() {
  try {
    const { execSync } = require('child_process');
    const username = execSync('git config user.name', { encoding: 'utf8' }).trim();
    if (username) return username;
  } catch {
    // git config 失败，尝试环境变量
  }
  // 回退到系统用户名
  return process.env.USER || process.env.USERNAME || 'unknown';
}

async function main() {
  const stdinData = await readStdin();

  let hookInput = {};
  try {
    hookInput = JSON.parse(stdinData);
  } catch {
    console.log('INVALID JSON, exiting');
    return;
  }

  const { transcript_path: transcriptPath, last_assistant_message: lastAssistantMessage } = hookInput;

  const projectRoot = findProjectRoot();
  const gitUsername = getGitUsername();
  const historyDir = path.join(projectRoot, 'docs', 'history', gitUsername);
  fs.mkdirSync(historyDir, { recursive: true });

  const persistentTranscript = path.join(historyDir, '.transcript-latest.jsonl');

  // 提取 user 消息
  let userMessages = [];
  let resolvedTranscriptPath = null;

  // 优先使用内置 transcript，不可用时回退到持久化副本
  if (transcriptPath && fs.existsSync(transcriptPath)) {
    resolvedTranscriptPath = transcriptPath;
  } else if (fs.existsSync(persistentTranscript)) {
    resolvedTranscriptPath = persistentTranscript;
    console.log('USING PERSISTENT TRANSCRIPT');
  } else {
    console.log('NO TRANSCRIPT OR PERSISTENT FILE, exiting');
    return;
  }

  try {
    const content = fs.readFileSync(resolvedTranscriptPath, 'utf8');
    const lines = content.split('\n');
    userMessages = extractUserMessages(lines, MAX_ROUNDS);
    console.log(`USERS_FOUND: ${userMessages.length}`);
  } catch (err) {
    console.log(`ERROR reading transcript: ${err.message}`);
    return;
  }

  // 构造 user + assistant 配对
  const pairs = [];
  if (lastAssistantMessage) {
    const lastUser = userMessages[userMessages.length - 1];
    if (lastUser?.uuid) {
      pairs.push({
        user_uuid: lastUser.uuid,
        user_ts: lastUser.ts,
        user_content: lastUser.content,
        assistant_content: lastAssistantMessage,
      });
      console.log(`PAIR_WRITTEN: user=${lastUser.uuid}`);
    }
  }

  if (pairs.length === 0) {
    console.log('NO PAIRS to write, exiting');
    return;
  }

  const date = new Date().toISOString().slice(0, 10).replace(/-/g, '');
  const existingUuids = collectExistingUuids(historyDir, date);

  let recordsWritten = 0;

  for (const pair of pairs) {
    if (!pair.user_uuid || existingUuids.has(pair.user_uuid)) {
      console.log(`SKIP: user=${pair.user_uuid} already exists`);
      continue;
    }

    console.log(`WRITING: user=${pair.user_uuid} content_len=${pair.user_content.length} assistant_len=${pair.assistant_content.length}`);

    const record = buildRecord(pair.user_uuid, pair.user_ts, pair.user_content, pair.assistant_content);

    const targetFile = findTargetFile(historyDir, date);
    ensureHeader(targetFile, date);

    fs.appendFileSync(targetFile, record, 'utf8');
    recordsWritten++;
  }

  console.log(`RECORDS_WRITTEN: ${recordsWritten}`);
}

main().catch(err => {
  console.error(`FATAL: ${err.message}`);
  process.exit(1);
});
