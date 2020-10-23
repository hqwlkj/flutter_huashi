package com.ysf.card.util;

import android.util.Log;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.serializer.SerializeConfig;
import com.alibaba.fastjson.serializer.SimpleDateFormatSerializer;

import java.util.Date;

/**
 * json 操作工具类
 */
public class FastJsonUtil
{
	private static final String TAG = FastJsonUtil.class.getSimpleName();
	
	private static final SerializeConfig serializeConfig = new SerializeConfig();

	static
	{
		serializeConfig.put(Date.class, new SimpleDateFormatSerializer("yyyy-MM-dd HH:mm:ss"));
	}

	/**
	 * 
	 * <p>将对象转成json字符串</p>
	 * @param obj 对象
	 * @return json字符串
	 */
	public static String toJson(Object obj)
	{
		return JSON.toJSONString(obj, serializeConfig);
	}

	/**
	 * 
	 * <p>将json字符串转成指定的对象</p>
	 * @param str json字符串
	 * @param clazz 指定对象的class对象
	 * @return
	 */
	public static <T> T fromJson(String str, Class<T> clazz)
	{
		try
		{
			return JSON.parseObject(str, clazz);

		}
		catch (Exception e)
		{
			Log.e(TAG, e.getLocalizedMessage(), e);
		}
		return null;
	}

	/**
	 * 
	 * <p>将二进制数据转成指定的对象</p>
	 * @param bytes 二进制数据
	 * @param clazz 指定的对象的class类型的对象
	 * @return 指定的对象
	 */
	public static <T> T fromJson(byte[] bytes, Class<T> clazz)
	{
		if (bytes != null && clazz != null)
		{
			try
			{
				return JSON.parseObject(new String(bytes, "UTF-8"), clazz);
			}
			catch (Exception e)
			{
				Log.e(TAG, e.getLocalizedMessage(),e);
			}
		}

		return null;
	}
	
	/**
	 * 
	 * <p>将二进制数据转成指定的对象</p>
	 * @param bytes 二进制数据
	 * @param clazz 指定的对象的class类型的对象
	 * @param encoding 指定的时间格式
	 * @return 指定的对象
	 */
	public static <T> T fromJson(byte[] bytes, Class<T> clazz, String encoding)
	{
		if (bytes != null && clazz != null)
		{
			try
			{
				return JSON.parseObject(new String(bytes, encoding), clazz);
			}
			catch (Exception e)
			{
				Log.e(TAG, e.getLocalizedMessage(),e);
			}
		}
		return null;
	}
}
