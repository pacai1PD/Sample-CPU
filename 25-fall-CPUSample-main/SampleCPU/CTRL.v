`include "lib/defines.vh"

// 定义CTRL模块，控制信号产生与处理
module CTRL(
    input wire rst,
    // input wire stallreq_for_ex,
    // input wire stallreq_for_load,
    input wire rst,  // 输入复位信号

    input wire stallreq_for_ex,    // 执行阶段暂停请求
    input wire stallreq_for_bru,   // 分支指令单元暂停请求
    input wire stallreq_for_load,  // 加载阶段暂停请求

    // 输出信号：流水线各阶段的暂停信号
    output reg [`StallBus-1:0] stall  // 暂停信号，控制流水线各阶段的暂停
);
    // stall[0] 表示取指地址 PC 是否保持不变，为1表示保持不变
    // stall[1] 表示流水线取指阶段是否暂停，为1表示暂停
    // stall[2] 表示流水线译码阶段是否暂停，为1表示暂停
    // stall[3] 表示流水线执行阶段是否暂停，为1表示暂停
    // stall[4] 表示流水线访存阶段是否暂停，为1表示暂停
    // stall[5] 表示流水线回写阶段是否暂停，为1表示暂停

    output reg [`StallBus-1:0] stall
);  
    // 根据不同的输入信号，生成合适的暂停信号
    always @ (*) begin
        if (rst) begin
            // 如果复位信号为1，所有流水线暂停信号都设为0，恢复正常
            stall = `StallBus'b0;
        end
        // 如果执行阶段（ex）有暂停请求
        else if (stallreq_for_ex) begin
            // 设置执行阶段及之后的所有阶段为暂停（即stall[0] = 0, stall[1] = 1, stall[2] = 1, stall[3] = 1, stall[4] = 1, stall[5] = 1）
            stall = `StallBus'b001111;
        end
        // 如果分支指令单元（bru）有暂停请求
        else if (stallreq_for_bru) begin
            // 设置分支指令单元阶段及之后的阶段为暂停（即stall[0] = 0, stall[1] = 0, stall[2] = 1, stall[3] = 1, stall[4] = 1, stall[5] = 1）
            stall = `StallBus'b000111;
        end
        // 暂时没有处理加载阶段（load）的暂停请求
        // else if (stallreq_for_load) begin
        //     // 设置加载阶段及之后的阶段为暂停（即stall[0] = 0, stall[1] = 0, stall[2] = 0, stall[3] = 1, stall[4] = 1, stall[5] = 1）
        //     stall = `StallBus'b000011;
        // end
        else begin
            // 如果没有任何暂停请求，则所有信号都为0，流水线正常执行
            stall = `StallBus'b0;
        end
    end

endmodule