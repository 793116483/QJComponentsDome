//
//  PPSysMemory.m
//  PatPat
//
//  Created by 杰 on 2022/10/20.
//  Copyright © 2022 http://www.patpat.com. All rights reserved.
//

#import "PPSysMemory.h"
#import <mach/mach.h>

@implementation PPSysMemory

+(CGFloat)getUsedRamMemory{
    int64_t memoryUsageInByte = 0;
    task_vm_info_data_t vmInfo;
    mach_msg_type_number_t count = TASK_VM_INFO_COUNT;
    kern_return_t kernelReturn = task_info(mach_task_self(), TASK_VM_INFO, (task_info_t) &vmInfo, &count);
    if(kernelReturn == KERN_SUCCESS) {
        memoryUsageInByte = (int64_t) vmInfo.phys_footprint;
        //    NSLog(@"已用: %u 可用: %u 总共: %u", mem_used/1024/1024, mem_free/1024/1024, mem_total/1024/1024);

//        NSLog(@"Memory in use (in bytes): %lld ， 总共：%lld", memoryUsageInByte/1024/1024,vmInfo.virtual_size/1024/1024);
        return memoryUsageInByte*1.0/1024/1024;
    } else {
//        NSLog(@"Error with task_info(): %s", mach_error_string(kernelReturn));
        return 0;
    }
}

+(CGFloat)getLimitRamMemory {
    task_vm_info_data_t vmInfo;
    mach_msg_type_number_t count = TASK_VM_INFO_COUNT;
    kern_return_t kernelReturn = task_info(mach_task_self(), TASK_VM_INFO, (task_info_t) &vmInfo, &count);
    if(kernelReturn == KERN_SUCCESS) {
        return vmInfo.limit_bytes_remaining*1.0/1024/1024;
    } else {
        return 0;
    }
}

+(CGFloat)usageRateForRamMemory {
    task_vm_info_data_t vmInfo;
    mach_msg_type_number_t count = TASK_VM_INFO_COUNT;
    kern_return_t kernelReturn = task_info(mach_task_self(), TASK_VM_INFO, (task_info_t) &vmInfo, &count);
    if(kernelReturn == KERN_SUCCESS && vmInfo.phys_footprint != 0) {
        // limit_bytes_remaining 如果为0，默认极限为 1.6G(1717986918)
        uint64_t limit_bytes_remaining = vmInfo.limit_bytes_remaining > 1717986918 ? vmInfo.limit_bytes_remaining:1717986918;
        return (vmInfo.phys_footprint*1.0 / limit_bytes_remaining) * 100;
    } else {
        return 0;
    }
}

+(BOOL)needClearMemory{
    CGFloat usageRate = [self usageRateForRamMemory];
    return usageRate > 70;
}

@end
