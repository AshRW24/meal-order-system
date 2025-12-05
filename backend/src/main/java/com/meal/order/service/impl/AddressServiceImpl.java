package com.meal.order.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.meal.order.entity.Address;
import com.meal.order.exception.BusinessException;
import com.meal.order.mapper.AddressMapper;
import com.meal.order.service.AddressService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * 地址服务实现类
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AddressServiceImpl implements AddressService {

    private final AddressMapper addressMapper;

    @Override
    public List<Address> listByUserId(Long userId) {
        log.info("查询用户地址列表，用户ID：{}", userId);

        LambdaQueryWrapper<Address> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Address::getUserId, userId)
                .orderByDesc(Address::getIsDefault)
                .orderByDesc(Address::getUpdateTime);

        return addressMapper.selectList(wrapper);
    }

    @Override
    public Address getById(Long userId, Long addressId) {
        log.info("查询地址详情，用户ID：{}，地址ID：{}", userId, addressId);

        Address address = addressMapper.selectById(addressId);
        if (address == null) {
            throw new BusinessException("地址不存在");
        }

        // 验证权限
        if (!address.getUserId().equals(userId)) {
            throw new BusinessException("无权限操作");
        }

        return address;
    }

    @Override
    @Transactional
    public void add(Long userId, Address address) {
        log.info("新增地址，用户ID：{}，地址信息：{}", userId, address);

        // 设置用户ID
        address.setUserId(userId);

        // 如果是第一个地址，自动设为默认地址
        LambdaQueryWrapper<Address> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Address::getUserId, userId);
        Long count = addressMapper.selectCount(wrapper);

        if (count == 0) {
            address.setIsDefault(1);
        } else {
            // 如果设置为默认地址，需要将其他地址的默认标识清除
            if (address.getIsDefault() != null && address.getIsDefault() == 1) {
                clearDefaultAddress(userId);
            } else {
                address.setIsDefault(0);
            }
        }

        addressMapper.insert(address);
    }

    @Override
    @Transactional
    public void update(Long userId, Address address) {
        log.info("更新地址，用户ID：{}，地址信息：{}", userId, address);

        // 验证地址是否存在及权限
        Address existAddress = getById(userId, address.getId());

        // 如果要设置为默认地址，需要先清除其他地址的默认标识
        if (address.getIsDefault() != null && address.getIsDefault() == 1) {
            clearDefaultAddress(userId);
        }

        // 更新地址信息
        addressMapper.updateById(address);
    }

    @Override
    @Transactional
    public void delete(Long userId, Long addressId) {
        log.info("删除地址，用户ID：{}，地址ID：{}", userId, addressId);

        // 验证地址是否存在及权限
        Address address = getById(userId, addressId);

        // 删除地址
        addressMapper.deleteById(addressId);

        // 如果删除的是默认地址，需要将第一个地址设为默认地址
        if (address.getIsDefault() == 1) {
            LambdaQueryWrapper<Address> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(Address::getUserId, userId)
                    .orderByDesc(Address::getUpdateTime)
                    .last("LIMIT 1");
            Address firstAddress = addressMapper.selectOne(wrapper);

            if (firstAddress != null) {
                firstAddress.setIsDefault(1);
                addressMapper.updateById(firstAddress);
            }
        }
    }

    @Override
    @Transactional
    public void setDefault(Long userId, Long addressId) {
        log.info("设置默认地址，用户ID：{}，地址ID：{}", userId, addressId);

        // 验证地址是否存在及权限
        getById(userId, addressId);

        // 先清除该用户所有地址的默认标识
        clearDefaultAddress(userId);

        // 设置当前地址为默认地址
        Address address = new Address();
        address.setId(addressId);
        address.setIsDefault(1);
        addressMapper.updateById(address);
    }

    @Override
    public Address getDefault(Long userId) {
        log.info("查询默认地址，用户ID：{}", userId);

        LambdaQueryWrapper<Address> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Address::getUserId, userId)
                .eq(Address::getIsDefault, 1);

        return addressMapper.selectOne(wrapper);
    }

    /**
     * 清除用户所有地址的默认标识
     *
     * @param userId 用户ID
     */
    private void clearDefaultAddress(Long userId) {
        LambdaUpdateWrapper<Address> wrapper = new LambdaUpdateWrapper<>();
        wrapper.eq(Address::getUserId, userId)
                .set(Address::getIsDefault, 0);
        addressMapper.update(null, wrapper);
    }
}
