//
//  ToastManager.swift
//  MyMap3
//
//  Created by Sie monyan on 2022/5/7.
//

import Foundation
import UIKit
public class ToastManager {
    
    // 单例
    public static let shared = ToastManager()
    
    // 默认样式
    public var style = ToastStyle()
    
    // 是否支持点击消失隐藏toast，默认是true
    public var isTapToDismissEnabled = true
    
    // 是否按照点击先后展示，还是立即展示出来
    public var isQueueEnabled = false
    
    // showToast 展示时间
    public var duration: TimeInterval = 3.0
    
    // 展示位置 ：默认是底部
    public var position: ToastPosition = .bottom
    
}
public enum ToastPosition {
    case top
    case center
    case bottom
}
public struct ToastStyle {

    public init() {}
      // 默认背景颜色
    public var backgroundColor: UIColor = UIColor.black.withAlphaComponent(0.8)
    // 标题颜色

    /// 最大宽度百分比
    public var maxWidthPercentage: CGFloat = 0.8 {
        didSet {
            maxWidthPercentage = max(min(maxWidthPercentage, 1.0), 0.0)
        }
    }
    public var maxHeightPercentage: CGFloat = 0.8 {
        didSet {
            maxHeightPercentage = max(min(maxHeightPercentage, 1.0), 0.0)
        }
    }

    public var horizontalPadding: CGFloat = 10.0
    public var verticalPadding: CGFloat = 10.0

}
