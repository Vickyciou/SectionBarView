//
//  ViewController.swift
//  SectionBarView
//
//  Created by Vicky on 2024/2/20.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var sectionBarView: LTSectionBarView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    private var mSectionViews: [UIView] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    private func setupViews(isHiddenArrangedSubviews: Bool) {
        mSectionViews.removeAll()
        var sectionTitles: [String] = []
        
        sectionBarView.setupView(sectionTitles: sectionTitles)
        sectionBarView.delegate = self
    
    }
    
    private func updateCurrentSection(_ scrollView: UIScrollView) {
        // 計算每個section視圖在scrollView座標系統中的Y軸起點位置
        let sectionViewPositions = mSectionViews.enumerated().map { index, view -> CGFloat in

            return scrollView.convert(view.frame, from: view.superview).origin.y +  (scrollView.contentOffset.y)
        }

        // 找到與當前scrollView的contentOffset.y加上頂部內距最接近的section視圖位置
        if let closestSectionIndex = sectionViewPositions.enumerated().min(by: { abs($0.element) < abs($1.element) })?.offset {
            sectionBarView.reloadData(toSection: closestSectionIndex)
        }
    }
    
    private func updateScrollViewPosition(view: UIView, plusOffset: CGFloat = 0) {
        let viewPositionInScrollView = scrollView.convert(view.frame.origin, from: view.superview)
        let targetContentOffsetY = viewPositionInScrollView.y
        
        // 計算UIScrollView的最大可能contentOffset（不考慮回彈）
        let maxPossibleContentOffsetY = scrollView.contentSize.height - scrollView.bounds.height + scrollView.contentInset.bottom
        
        // 如果計算後的contentOffset超過了最大可能值，則將其設置為最大可能值
        let adjustedContentOffsetY = min(targetContentOffsetY, maxPossibleContentOffsetY)
        
        // 更新UIScrollView的contentOffset
        scrollView.setContentOffset(CGPoint(x: 0, y: adjustedContentOffsetY), animated: true)
    }

}

extension ViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        self.setNeedsStatusBarAppearanceUpdate()
        updateCurrentSection(scrollView)
    }
}

extension ViewController: LTSectionBarViewDelegate {
    func lTSectionBarView(_ view: LTSectionBarView, sectionIndex index: Int) {
        if index < mSectionViews.count {
            let targetView = mSectionViews[index]
            updateScrollViewPosition(view: targetView, plusOffset: 1)
            }
        }
    }
    
    

