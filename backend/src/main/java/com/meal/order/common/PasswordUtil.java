package com.meal.order.common;

import java.security.MessageDigest;
import java.util.UUID;

/**
 * 密码加密工具类
 * 使用 SHA1 + 随机盐值进行密码加密
 */
public class PasswordUtil {

    /**
     * 加密密码
     *
     * @param password 原始密码
     * @param username 用户名（用作盐值的一部分）
     * @return 加密后的密码 格式：salt$hash
     */
    public static String encode(String password, String username) {
        if (password == null || password.isEmpty()) {
            throw new IllegalArgumentException("密码不能为空");
        }
        if (username == null || username.isEmpty()) {
            throw new IllegalArgumentException("用户名不能为空");
        }

        // 生成盐值：用户名 + UUID的一部分
        String randomPart = UUID.randomUUID().toString().substring(0, 8);
        String salt = username + randomPart;

        // SHA1加密
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-1");
            String combined = password + salt;
            byte[] messageDigest = md.digest(combined.getBytes());

            // 转换为16进制字符串
            StringBuilder hash = new StringBuilder();
            for (byte b : messageDigest) {
                hash.append(String.format("%02x", b));
            }

            // 返回 salt$hash 格式，以便验证时能提取盐值
            return salt + "$" + hash.toString();
        } catch (Exception e) {
            throw new RuntimeException("密码加密失败", e);
        }
    }

    /**
     * 验证密码
     *
     * @param password 原始密码
     * @param encoded  加密后的密码
     * @return 密码是否匹配
     */
    public static boolean verify(String password, String encoded) {
        if (password == null || encoded == null) {
            return false;
        }

        try {
            // 从编码的密码中提取盐值
            String[] parts = encoded.split("\\$");
            if (parts.length != 2) {
                return false;
            }

            String salt = parts[0];
            String storedHash = parts[1];

            // 使用相同的盐值重新加密输入的密码
            MessageDigest md = MessageDigest.getInstance("SHA-1");
            String combined = password + salt;
            byte[] messageDigest = md.digest(combined.getBytes());

            // 转换为16进制字符串
            StringBuilder hash = new StringBuilder();
            for (byte b : messageDigest) {
                hash.append(String.format("%02x", b));
            }

            // 比较哈希值
            return hash.toString().equals(storedHash);
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * 测试方法
     */
    public static void main(String[] args) {
        String password = "123456";
        String username = "user1";

        // 加密
        String encoded = encode(password, username);
        System.out.println("原始密码: " + password);
        System.out.println("加密后: " + encoded);

        // 验证
        boolean verified = verify(password, encoded);
        System.out.println("验证结果: " + verified);

        // 验证错误密码
        boolean wrongVerified = verify("wrongpass", encoded);
        System.out.println("验证错误密码: " + wrongVerified);
    }
}
