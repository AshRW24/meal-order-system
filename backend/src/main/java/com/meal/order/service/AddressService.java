package com.meal.order.service;

import com.meal.order.entity.Address;

import java.util.List;

/**
 * 地址服务接口
 */
public interface AddressService {

    /**
     * 查询用户的所有地址
     *
     * @param userId 用户ID
     * @return 地址列表
     */
    List<Address> listByUserId(Long userId);

    /**
     * 根据ID查询地址
     *
     * @param userId    用户ID
     * @param addressId 地址ID
     * @return 地址信息
     */
    Address getById(Long userId, Long addressId);

    /**
     * 新增地址
     *
     * @param userId  用户ID
     * @param address 地址信息
     */
    void add(Long userId, Address address);

    /**
     * 更新地址
     *
     * @param userId  用户ID
     * @param address 地址信息
     */
    void update(Long userId, Address address);

    /**
     * 删除地址
     *
     * @param userId    用户ID
     * @param addressId 地址ID
     */
    void delete(Long userId, Long addressId);

    /**
     * 设置默认地址
     *
     * @param userId    用户ID
     * @param addressId 地址ID
     */
    void setDefault(Long userId, Long addressId);

    /**
     * 查询默认地址
     *
     * @param userId 用户ID
     * @return 默认地址
     */
    Address getDefault(Long userId);
}
