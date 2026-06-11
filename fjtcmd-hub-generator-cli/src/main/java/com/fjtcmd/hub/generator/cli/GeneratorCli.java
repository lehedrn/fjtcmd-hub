package com.fjtcmd.hub.generator.cli;

import java.io.File;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.fjtcmd.hub.generator.config.GenConfig;
import com.fjtcmd.hub.generator.domain.GenTable;

/**
 * 代码生成 CLI 主入口
 * <p>
 * 用法：
 * <pre>
 * java -jar fjtcmd-hub-generator-cli-1.0.0.jar --config config/generator.yml --sql sql/create.sql --output ./generated
 * java -jar fjtcmd-hub-generator-cli-1.0.0.jar --config config/generator.yml --sql sql/create.sql --preview
 * </pre>
 * <p>
 * 流程：
 * <ol>
 *   <li>解析命令行参数</li>
 *   <li>加载 YAML 配置</li>
 *   <li>将 global 配置写入 GenConfig 静态字段</li>
 *   <li>DdlParser 解析 DDL（内部调用 GenUtils.initTable + initColumnField）</li>
 *   <li>ConfigLoader 应用三层配置覆盖（全局→表级→列级）</li>
 *   <li>CodeWriter 渲染模板并输出</li>
 * </ol>
 */
public class GeneratorCli
{
    private static final Logger log = LoggerFactory.getLogger(GeneratorCli.class);

    public static void main(String[] args)
    {
        try
        {
            run(args);
        }
        catch (Exception e)
        {
            log.error("代码生成失败: {}", e.getMessage(), e);
            System.exit(1);
        }
    }

    private static void run(String[] args) throws Exception
    {
        // 1. 解析命令行参数
        CliArgs cliArgs = parseArgs(args);

        if (cliArgs.help)
        {
            printHelp();
            return;
        }

        if (cliArgs.configPath == null)
        {
            System.err.println("错误: 必须指定配置文件 --config <path>");
            System.exit(1);
        }

        if (cliArgs.sqlPath == null)
        {
            System.err.println("错误: 必须指定 DDL SQL 文件 --sql <path>");
            System.exit(1);
        }

        // 2. 加载 YAML 配置
        log.info("加载配置文件: {}", new File(cliArgs.configPath).getAbsolutePath());
        GenCliConfig config = ConfigLoader.load(cliArgs.configPath);

        // 命令行 --output 覆盖配置中的 output
        if (cliArgs.outputPath != null && config.getGlobal() != null)
        {
            config.getGlobal().setOutput(cliArgs.outputPath);
        }
        if (cliArgs.overwrite && config.getGlobal() != null)
        {
            config.getGlobal().setAllowOverwrite(true);
        }

        // 确定输出目录
        String outputDir = "./generated";
        boolean allowOverwrite = false;
        if (config.getGlobal() != null)
        {
            if (config.getGlobal().getOutput() != null)
            {
                outputDir = config.getGlobal().getOutput();
            }
            allowOverwrite = Boolean.TRUE.equals(config.getGlobal().getAllowOverwrite());
        }

        // 3. 将 global 配置写入 GenConfig 静态字段（影响 DdlParser 中 GenUtils.initTable 的行为）
        ConfigLoader.applyGlobalToGenConfig(config);

        // 4. 解析 DDL
        File sqlFile = new File(cliArgs.sqlPath);
        if (!sqlFile.exists())
        {
            System.err.println("错误: SQL 文件不存在: " + sqlFile.getAbsolutePath());
            System.exit(1);
        }

        String ddlSql = Files.readString(sqlFile.toPath(), StandardCharsets.UTF_8);
        String operName = GenConfig.getAuthor() != null ? GenConfig.getAuthor() : "cli";
        log.info("解析 DDL 文件: {}", sqlFile.getAbsolutePath());

        List<GenTable> tables = DdlParser.parse(ddlSql, operName);
        if (tables.isEmpty())
        {
            System.err.println("错误: 未在 SQL 文件中找到 CREATE TABLE 语句");
            System.exit(1);
        }
        log.info("解析到 {} 张表", tables.size());

        // 5. 应用三层配置覆盖
        ConfigLoader.applyConfig(tables, config);

        // 6. 输出代码
        if (cliArgs.preview)
        {
            CodeWriter.preview(tables);
        }
        else
        {
            CodeWriter.writeToDir(tables, outputDir, allowOverwrite);
        }

        // 打印生成摘要
        log.info("生成表清单：");
        for (GenTable table : tables)
        {
            log.info("  - {} ({}) → {} [tpl={}, web={}, pkg={}]",
                    table.getTableName(),
                    table.getTableComment(),
                    table.getClassName(),
                    table.getTplCategory(),
                    table.getTplWebType(),
                    table.getPackageName());
        }
    }

    /**
     * 解析命令行参数
     */
    private static CliArgs parseArgs(String[] args)
    {
        CliArgs cliArgs = new CliArgs();
        for (int i = 0; i < args.length; i++)
        {
            String arg = args[i];
            if (arg.startsWith("--"))
            {
                // 支持 --key=value 和 --key value 两种格式
                String key;
                String value = null;
                int eqIdx = arg.indexOf('=');
                if (eqIdx > 0)
                {
                    key = arg.substring(2, eqIdx);
                    value = arg.substring(eqIdx + 1);
                }
                else
                {
                    key = arg.substring(2);
                    if (i + 1 < args.length && !args[i + 1].startsWith("--"))
                    {
                        value = args[++i];
                    }
                }

                switch (key)
                {
                    case "config":
                        cliArgs.configPath = value;
                        break;
                    case "sql":
                        cliArgs.sqlPath = value;
                        break;
                    case "output":
                        cliArgs.outputPath = value;
                        break;
                    case "preview":
                        cliArgs.preview = true;
                        break;
                    case "overwrite":
                        cliArgs.overwrite = true;
                        break;
                    case "help":
                    case "h":
                        cliArgs.help = true;
                        break;
                    default:
                        System.err.println("未知参数: --" + key);
                        break;
                }
            }
        }
        return cliArgs;
    }

    /**
     * 打印帮助信息
     */
    private static void printHelp()
    {
        System.out.println("fjtcmd-hub 代码生成 CLI 工具");
        System.out.println();
        System.out.println("用法:");
        System.out.println("  java -jar fjtcmd-hub-generator-cli.jar [选项]");
        System.out.println();
        System.out.println("必填参数:");
        System.out.println("  --config <path>          全局配置 YAML 文件路径");
        System.out.println("  --sql <path>             CREATE TABLE SQL 文件路径");
        System.out.println();
        System.out.println("可选参数:");
        System.out.println("  --output <path>          输出目录（覆盖配置中的 output）");
        System.out.println("  --overwrite              允许覆盖已存在的文件");
        System.out.println("  --preview                预览模式：输出到 stdout 不写文件");
        System.out.println("  --help, -h               显示帮助信息");
        System.out.println();
        System.out.println("示例:");
        System.out.println("  java -jar fjtcmd-hub-generator-cli.jar --config config/generator.yml --sql sql/create.sql --output ./generated");
        System.out.println("  java -jar fjtcmd-hub-generator-cli.jar --config config/generator.yml --sql sql/create.sql --preview");
    }

    /**
     * 命令行参数
     */
    static class CliArgs
    {
        String configPath;
        String sqlPath;
        String outputPath;
        boolean preview;
        boolean overwrite;
        boolean help;
    }
}
