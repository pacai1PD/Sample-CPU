// 引入全局宏定义文件，包含StallBus等自定义位宽/常量定义
`include "lib/defines.vh"

// 流水线暂停控制模块（CTRL）
// 功能：根据不同阶段的暂停请求（执行阶段、分支单元、加载指令），生成流水线各阶段的暂停信号
// 核心作用：协调CPU流水线各阶段的执行节奏，解决数据相关、分支跳转等导致的流水线暂停需求
module CTRL(
    input wire rst,                  // 全局复位信号（高电平有效），复位时清空所有暂停信号

    // 各模块的暂停请求输入（高电平表示请求暂停流水线）
    input wire stallreq_for_ex,      // 执行阶段（EX）的暂停请求（如复杂运算、异常处理）
    input wire stallreq_for_bru,     // 分支单元（BRU）的暂停请求（如分支跳转地址未确定）
    input wire stallreq_for_load,    // 加载指令（LOAD）的暂停请求（如数据加载未完成，需等待访存）

    // 注释掉的刷新/新PC信号（预留分支跳转刷新流水线的扩展接口）
    // output reg flush,              // 流水线刷新信号（高电平表示清空流水线无效指令）
    // output reg [31:0] new_pc,      // 刷新流水线后的新PC值（分支跳转时使用）
    
    output reg [`StallBus-1:0] stall // 流水线暂停总线（位宽由StallBus宏定义），每一位对应一个流水线阶段的暂停控制
);
    // 流水线暂停总线（stall）各位定义（从低位到高位）：
    // stall[0]：取指地址PC保持信号 → 1=PC地址不变（不取下一条指令），0=PC正常递增
    // stall[1]：取指阶段（IF）暂停信号 → 1=取指阶段暂停，0=正常执行
    // stall[2]：译码阶段（ID）暂停信号 → 1=译码阶段暂停，0=正常执行
    // stall[3]：执行阶段（EX）暂停信号 → 1=执行阶段暂停，0=正常执行
    // stall[4]：访存阶段（MEM）暂停信号 → 1=访存阶段暂停，0=正常执行
    // stall[5]：回写阶段（WB）暂停信号 → 1=回写阶段暂停，0=正常执行
    // （注：StallBus位宽大于6，高位预留未使用）

    // 组合逻辑块：无时钟触发，敏感列表包含所有输入信号（@(*)）
    // 功能：根据不同暂停请求的优先级，生成最终的流水线暂停信号
    always @ (*) begin
        // 复位优先级最高：复位时清空所有暂停信号，流水线恢复正常执行
        if (rst) begin
            stall = `StallBus'b0;    // 所有阶段暂停信号置0，流水线无暂停
        end
        // 优先级1：执行阶段（EX）暂停请求 → 暂停取指、译码、执行阶段（PC保持）
        // stall = 001111 二进制解析：
        // bit0=1（PC保持）、bit1=1（取指暂停）、bit2=1（译码暂停）、bit3=1（执行暂停）
        // bit4=0（访存正常）、bit5=0（回写正常）（高位补0）
        else if (stallreq_for_ex) begin
            stall = `StallBus'b001111;
        end
        // 优先级2：分支单元（BRU）暂停请求 → 暂停取指、译码阶段（PC保持）
        // stall = 000111 二进制解析：
        // bit0=1（PC保持）、bit1=1（取指暂停）、bit2=1（译码暂停）
        // bit3=0（执行正常）、bit4=0（访存正常）、bit5=0（回写正常）（高位补0）
        else if (stallreq_for_bru) begin
            stall = `StallBus'b000111;
        end

        // 预留：加载指令（LOAD）暂停请求（当前注释，可启用）
        // 优先级3：加载指令暂停请求 → 仅暂停取指阶段（PC保持）
        // stall = 000011 二进制解析：
        // bit0=1（PC保持）、bit1=1（取指暂停）
        // bit2=0（译码正常）、bit3=0（执行正常）、bit4=0（访存正常）、bit5=0（回写正常）
        // else if (stallreq_for_load) begin
        //     stall = `StallBus'b000011;
        // end

        // 无任何暂停请求：所有阶段暂停信号置0，流水线正常执行
        else begin
            stall = `StallBus'b0;
        end
    end

endmodule