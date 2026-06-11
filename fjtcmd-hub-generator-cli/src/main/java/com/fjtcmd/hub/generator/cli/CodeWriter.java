package com.fjtcmd.hub.generator.cli;

import java.io.File;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.apache.velocity.Template;
import org.apache.velocity.VelocityContext;
import org.apache.velocity.app.Velocity;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.fjtcmd.hub.common.constant.Constants;
import com.fjtcmd.hub.generator.domain.GenTable;
import com.fjtcmd.hub.generator.domain.GenTableColumn;
import com.fjtcmd.hub.generator.util.VelocityInitializer;
import com.fjtcmd.hub.generator.util.VelocityUtils;

/**
 * 代码输出器
 * <p>
 * 将 GenTable 渲染为代码文件，输出到目录或 stdout（预览模式）。
 */
public class CodeWriter
{
    private static final Logger log = LoggerFactory.getLogger(CodeWriter.class);

    /**
     * 将多张表的代码写入目录
     *
     * @param tables       已解析的 GenTable 列表
     * @param outputDir    输出根目录
     * @param allowOverwrite 是否允许覆盖
     */
    public static void writeToDir(List<GenTable> tables, String outputDir, boolean allowOverwrite) throws IOException
    {
        // 建立主子表关联
        linkSubTables(tables);

        // 收集子表名（子表的代码在主表中一起生成，不单独生成）
        Set<String> subTableNames = new HashSet<>();
        for (GenTable table : tables)
        {
            if (table.getSubTableName() != null && !table.getSubTableName().isEmpty())
            {
                subTableNames.add(table.getSubTableName());
            }
        }

        // 初始化 Velocity 引擎（只需一次）
        VelocityInitializer.initVelocity();

        File outDir = new File(outputDir);
        if (!outDir.exists())
        {
            outDir.mkdirs();
        }

        int totalCount = 0;
        for (GenTable table : tables)
        {
            if (subTableNames.contains(table.getTableName()))
            {
                log.info("跳过子表 {} 的独立代码生成（将在主表中生成）", table.getTableName());
                continue;
            }
            int count = generateTable(table, outputDir, allowOverwrite);
            totalCount += count;
        }

        log.info("========== 生成完成 ==========");
        log.info("共生成 {} 个文件，输出目录: {}", totalCount, new File(outputDir).getAbsolutePath());
    }

    /**
     * 预览模式：输出到 stdout
     */
    public static void preview(List<GenTable> tables) throws Exception
    {
        linkSubTables(tables);
        VelocityInitializer.initVelocity();

        System.out.println("========== 预览生成代码 ==========\n");
        for (GenTable table : tables)
        {
            setPkColumn(table);
            VelocityContext context = VelocityUtils.prepareContext(table);
            List<String> templates = VelocityUtils.getTemplateList(table);

            System.out.println("========== 表: " + table.getTableName() + " ==========\n");
            for (String template : templates)
            {
                java.io.StringWriter sw = new java.io.StringWriter();
                Template tpl = Velocity.getTemplate(template, Constants.UTF8);
                tpl.merge(context, sw);
                System.out.println("--- " + template + " ---");
                System.out.println(sw.toString());
                System.out.println();
            }
        }
        System.out.println("========== 预览结束 ==========");
    }

    /**
     * 为单张表生成代码写入目录
     *
     * @return 生成的文件数量
     */
    private static int generateTable(GenTable table, String outputDir, boolean allowOverwrite) throws IOException
    {
        log.info("开始生成表 {} 的代码 [tpl={}, web={}, pkg={}]",
                table.getTableName(),
                table.getTplCategory(),
                table.getTplWebType(),
                table.getPackageName());

        setPkColumn(table);

        VelocityContext context = VelocityUtils.prepareContext(table);
        List<String> templates = VelocityUtils.getTemplateList(table);

        int count = 0;
        for (String template : templates)
        {
            java.io.StringWriter sw = new java.io.StringWriter();
            Template tpl = Velocity.getTemplate(template, Constants.UTF8);
            tpl.merge(context, sw);

            String fileName = VelocityUtils.getFileName(template, table);
            Path filePath = Paths.get(outputDir, fileName);

            // 创建目录
            Files.createDirectories(filePath.getParent());

            // 检查文件是否已存在
            if (Files.exists(filePath) && !allowOverwrite)
            {
                log.warn("跳过已存在的文件: {}", filePath);
                continue;
            }

            // 写入文件
            Files.writeString(filePath, sw.toString(), StandardCharsets.UTF_8);
            log.info("生成: {}", filePath);
            count++;
        }
        return count;
    }

    /**
     * 建立主子表关联
     */
    private static void linkSubTables(List<GenTable> tables)
    {
        for (GenTable table : tables)
        {
            String subTableName = table.getSubTableName();
            if (subTableName != null && !subTableName.isEmpty())
            {
                for (GenTable subTable : tables)
                {
                    if (subTable.getTableName().equals(subTableName))
                    {
                        table.setSubTable(subTable);
                        log.info("建立主子表关联: {} → {}", table.getTableName(), subTableName);
                        break;
                    }
                }
                if (table.getSubTable() == null)
                {
                    log.warn("未找到子表 {}", subTableName);
                }
            }
        }
    }

    /**
     * 设置主键列
     */
    private static void setPkColumn(GenTable table)
    {
        for (GenTableColumn column : table.getColumns())
        {
            if (column.isPk())
            {
                table.setPkColumn(column);
                return;
            }
        }
        // 没有显式主键，默认取第一个列
        if (!table.getColumns().isEmpty())
        {
            table.setPkColumn(table.getColumns().get(0));
        }
    }
}
