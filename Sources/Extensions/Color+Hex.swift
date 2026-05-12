// ============================================================
// 文件: Color+Hex.swift
// 模块: Extensions
// 作用: 为 SwiftUI 的 Color 类型添加十六进制颜色字符串初始化能力，
//       方便从设计稿中直接使用 HEX 色值创建颜色。
// ============================================================

import SwiftUI

// MARK: - Color 十六进制初始化扩展
extension Color {
    
    /// 通过十六进制字符串创建颜色
    /// - Parameters:
    ///   - hex: 十六进制颜色字符串，支持 "#RRGGBB" 或 "RRGGBB" 格式
    ///   - opacity: 透明度，默认为 1.0（完全不透明）
    /// - 使用示例: Color(hex: "#8FAED9") 或 Color(hex: "8FAED9")
    init(hex: String, opacity: Double = 1.0) {
        // 去除字符串中的 "#" 前缀和空格
        let cleanedHex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
        
        // 将十六进制字符串转换为 UInt64 数值
        var rgbValue: UInt64 = 0
        Scanner(string: cleanedHex).scanHexInt64(&rgbValue)
        
        // 从数值中提取红、绿、蓝三个通道的值（每个通道 8 位）
        let red = Double((rgbValue & 0xFF0000) >> 16) / 255.0    // 提取红色通道
        let green = Double((rgbValue & 0x00FF00) >> 8) / 255.0   // 提取绿色通道
        let blue = Double(rgbValue & 0x0000FF) / 255.0           // 提取蓝色通道
        
        // 使用提取的 RGB 值创建 Color
        self.init(
            .sRGB,
            red: red,
            green: green,
            blue: blue,
            opacity: opacity
        )
    }
}
