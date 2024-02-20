//
//  LTSectionBarView.swift
//  SectionBarView
//
//  Created by Vicky on 2024/2/20.
//

import UIKit

protocol LTSectionBarViewDelegate: AnyObject {
    func lTSectionBarView(_ view: LTSectionBarView, sectionIndex index: Int)
}

class LTSectionBarView: BaseXibView {
    @IBOutlet weak private var mScrollView: UIScrollView!
    @IBOutlet weak private var mStackView: UIStackView!
    @IBOutlet weak private var mRedLineView: UIView!
    private lazy var normalAttr = setAttributedTitle(fontSize: 14, fontWeight: .regular, color: .black)
    private lazy var selectedAttr = setAttributedTitle(fontSize: 14, fontWeight: .medium, color: .red)
    weak var delegate: LTSectionBarViewDelegate?
    private var sectionButtons: [UIButton] = []
    private var mCurrentSection: Int = 0 {
        willSet {
            if newValue != mCurrentSection {
                sectionButtons.forEach { $0.isSelected = false }
            }
        }
        didSet {
            sectionButtons[mCurrentSection].isSelected = true
            scrollToButtonIfNeeded(at: mCurrentSection)
            updateRedLineViewCenterX(toAlignWith: sectionButtons[mCurrentSection])
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        mScrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        mScrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16)
    }
    
    func setupView(sectionTitles: [String],
                   normalAttr: [NSAttributedString.Key: Any]? = nil,
                   selectedAttr: [NSAttributedString.Key: Any]? = nil) {
        mStackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
            mStackView.removeArrangedSubview($0)
        }
        sectionButtons.removeAll()
        
        for (index, title) in sectionTitles.enumerated() {
            let button = UIButton()
            button.tag = index
            let normalAttrTitle = NSAttributedString(string: title, attributes: normalAttr ?? self.normalAttr)
            let selectedAttrTitle = NSAttributedString(string: title, attributes: selectedAttr ?? self.selectedAttr)
            button.setAttributedTitle(normalAttrTitle, for: .normal)
            button.setAttributedTitle(selectedAttrTitle, for: .selected)
            button.addTarget(self, action: #selector(onClickButtonHandler(_:)), for: .touchUpInside)
            button.setContentCompressionResistancePriority(.required, for: .horizontal)
            button.setContentCompressionResistancePriority(.required, for: .vertical)
            
            var config = UIButton.Configuration.plain()
            config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
            button.configuration = config
            
            sectionButtons.append(button)
            mStackView.addArrangedSubview(button)
        }
    }

    func reloadData(toSection index: Int) {
        mCurrentSection = index
    }
    
    private func updateRedLineViewCenterX(toAlignWith targetSection: UIButton) {
        mRedLineView.translatesAutoresizingMaskIntoConstraints = false
        
        if let superview = mRedLineView.superview {
            for constraint in superview.constraints {
                if constraint.firstItem as? UIView == mRedLineView || constraint.secondItem as? UIView == mRedLineView {
                    superview.removeConstraint(constraint)
                }
            }
        }
        NSLayoutConstraint.activate([
            mRedLineView.heightAnchor.constraint(equalToConstant: 3),
            mRedLineView.widthAnchor.constraint(equalToConstant: 60),
            mRedLineView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            mRedLineView.centerXAnchor.constraint(equalTo: targetSection.centerXAnchor)
        ])
    }

    private func scrollToButtonIfNeeded(at index: Int, animated: Bool = true) {
        guard index >= 0 && index < sectionButtons.count else { return }
        
        let targetButton = sectionButtons[index]
        
        guard let scrollView = mStackView.superview as? UIScrollView else { return }
        
        var buttonFrame = targetButton.frame
        buttonFrame = mStackView.convert(buttonFrame, to: scrollView)
        
        // 判斷按鈕是否完全在可視範圍內
        let isVisible = scrollView.bounds.contains(buttonFrame)
        // 如果按鈕未完全出現在畫面上，計算滾動到按鈕的位置
        if !isVisible {
            var offset = scrollView.contentOffset
            // 按鈕左側未完全顯示
            if buttonFrame.minX < scrollView.contentOffset.x {
                let targetX = buttonFrame.minX - scrollView.contentInset.left
                offset.x = targetX
            }
            // 按鈕右側未完全顯示
            else if buttonFrame.maxX > scrollView.contentOffset.x + scrollView.bounds.width {
                let targetX = buttonFrame.maxX - scrollView.bounds.width
                offset.x = targetX + scrollView.contentInset.right
            }

            offset.x = min(offset.x, scrollView.contentSize.width - scrollView.bounds.width)
            scrollView.setContentOffset(offset, animated: animated)
        }
    }
    
    // 設置 sectionTitle 的字體
    private func setAttributedTitle(fontSize: CGFloat, fontWeight: UIFont.Weight, color: UIColor) -> [NSAttributedString.Key: Any] {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: fontSize, weight: fontWeight),
            .foregroundColor: color
        ]
        return attributes
    }
    
    @objc private func onClickButtonHandler(_ sender: UIButton) {
        delegate?.lTSectionBarView(self, sectionIndex: sender.tag)
    }
}

