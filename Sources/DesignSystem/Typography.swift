// ============================================================
// 文件: Typography.swift
// 模块: DesignSystem
// 作用: 定义 GracePiper 应用的字体系统。
//       包含标题字体（Cormorant Garamond 衬线体）和正文字体（Inter 无衬线体），
//       以及完整的字体尺度系统，确保全局排版一致。
// ============================================================

import SwiftUI

// MARK: - 字体系统命名空间
/// GracePiper 字体排版系统
/// 使用方式: GPTypography.h1 或 Text("标题").font(GPTypography.h1)
enum GPTypography {
    
    // MARK: - 字体族名称定义
    
    /// 标题字体族 - Cormorant Garamond（优雅衬线体）
    /// 如果未安装自定义字体，回退使用系统 serif 字体
    private static let headingFontName = "CormorantGaramond-Regular"
    
    /// 标题字体族（加粗版本）
    private static let headingBoldFontName = "CormorantGaramond-Bold"
    
    /// 正文字体族 - Inter（现代无衬线体）
    /// 如果未安装自定义字体，回退使用系统默认字体
    private static let bodyFontName = "Inter-Regular"
    
    /// 正文字体族（中等粗细）
    private static let bodyMediumFontName = "Inter-Medium"
    
    /// 正文字体族（半粗）
    private static let bodySemiBoldFontName = "Inter-SemiBold"
    
    // MARK: - 字体尺度定义（单位: pt）
    
    /// 超大标题尺寸 - 用于闪屏、主标题
    static let sizeH1: CGFloat = 40
    
    /// 大标题尺寸 - 用于页面标题
    static let sizeH2: CGFloat = 32
    
    /// 中标题尺寸 - 用于区块标题
    static let sizeH3: CGFloat = 24
    
    /// 大号正文尺寸 - 用于重要说明文字
    static let sizeBodyLarge: CGFloat = 18
    
    /// 标准正文尺寸 - 用于常规正文
    static let sizeBody: CGFloat = 16
    
    /// 说明文字尺寸 - 用于辅助信息、标签
    static let sizeCaption: CGFloat = 14
    
    /// 最小文字尺寸 - 用于时间戳、版权信息等
    static let sizeTiny: CGFloat = 12
    
    // MARK: - 标题字体（Heading）— 衬线体
    
    /// H1 超大标题字体 - 40pt 衬线体
    /// 用于：闪屏 Logo 文字、核心标语
    static let h1: Font = .custom(headingFontName, size: sizeH1, relativeTo: .largeTitle)
    
    /// H1 加粗版本
    static let h1Bold: Font = .custom(headingBoldFontName, size: sizeH1, relativeTo: .largeTitle)
    
    /// H2 大标题字体 - 32pt 衬线体
    /// 用于：页面主标题
    static let h2: Font = .custom(headingFontName, size: sizeH2, relativeTo: .title)
    
    /// H2 加粗版本
    static let h2Bold: Font = .custom(headingBoldFontName, size: sizeH2, relativeTo: .title)
    
    /// H3 中标题字体 - 24pt 衬线体
    /// 用于：区块标题、卡片标题
    static let h3: Font = .custom(headingFontName, size: sizeH3, relativeTo: .title2)
    
    /// H3 加粗版本
    static let h3Bold: Font = .custom(headingBoldFontName, size: sizeH3, relativeTo: .title2)
    
    // MARK: - 正文字体（Body）— 无衬线体
    
    /// 大号正文字体 - 18pt 无衬线体
    /// 用于：重要说明、引导文字
    static let bodyLarge: Font = .custom(bodyFontName, size: sizeBodyLarge, relativeTo: .body)
    
    /// 大号正文（中等粗细）
    static let bodyLargeMedium: Font = .custom(bodyMediumFontName, size: sizeBodyLarge, relativeTo: .body)
    
    /// 标准正文字体 - 16pt 无衬线体
    /// 用于：常规正文、列表项文字
    static let body: Font = .custom(bodyFontName, size: sizeBody, relativeTo: .body)
    
    /// 标准正文（中等粗细）
    static let bodyMedium: Font = .custom(bodyMediumFontName, size: sizeBody, relativeTo: .body)
    
    /// 标准正文（半粗）
    static let bodySemiBold: Font = .custom(bodySemiBoldFontName, size: sizeBody, relativeTo: .body)
    
    /// 说明文字字体 - 14pt 无衬线体
    /// 用于：辅助说明、标签、按钮文字
    static let caption: Font = .custom(bodyFontName, size: sizeCaption, relativeTo: .caption)
    
    /// 说明文字（中等粗细）
    static let captionMedium: Font = .custom(bodyMediumFontName, size: sizeCaption, relativeTo: .caption)
    
    /// 最小文字字体 - 12pt 无衬线体
    /// 用于：时间戳、版权信息、角标
    static let tiny: Font = .custom(bodyFontName, size: sizeTiny, relativeTo: .caption2)
    
    // MARK: - 备选系统字体（当自定义字体不可用时使用）
    
    /// 系统衬线标题字体（备选方案）
    static let systemHeading: Font = .system(size: sizeH1, weight: .regular, design: .serif)
    
    /// 系统无衬线正文字体（备选方案）
    static let systemBody: Font = .system(size: sizeBody, weight: .regular, design: .default)
}
