package com.fjtcmd.hub.common.exception.file;

import com.fjtcmd.hub.common.exception.base.BaseException;

/**
 * 文件信息异常类
 * 
 * @author fjtcmd
 */
public class FileException extends BaseException
{
    private static final long serialVersionUID = 1L;

    public FileException(String code, Object[] args)
    {
        super("file", code, args, null);
    }

}
