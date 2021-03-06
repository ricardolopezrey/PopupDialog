//
//  PopupDialogContainerView.swift
//  Pods
//
//  Copyright (c) 2016 Orderella Ltd. (http://orderella.co.uk)
//  Author - Martin Wildfeuer (http://www.mwfire.de)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import UIKit

/// The main view of the popup dialog
open class PopupDialogContainerView: UIView {

    private var leadingConstraint : NSLayoutConstraint!
    private var trailingConstraint : NSLayoutConstraint!
    
    private var widthConstraint : NSLayoutConstraint!
    
    private var _padding : CGFloat = 50
    public var padding : CGFloat {
        get {
            return _padding
        }
        set {
            _padding = newValue
            
            leadingConstraint.constant = newValue
            trailingConstraint.constant = newValue
            widthConstraint.constant = -(newValue * 2)
            self.updateConstraints()
        }
    }
    
    // MARK: - Appearance

    /// The background color of the popup dialog
    override open dynamic var backgroundColor: UIColor? {
        get { return container.backgroundColor }
        set { container.backgroundColor = newValue }
    }

    /// The corner radius of the popup view
    public dynamic var cornerRadius: Float {
        get { return Float(shadowContainer.layer.cornerRadius) }
        set {
            let radius = CGFloat(newValue)
            shadowContainer.layer.cornerRadius = radius
            container.layer.cornerRadius = radius
        }
    }

    /// Enable / disable shadow rendering
    public dynamic var shadowEnabled: Bool {
        get { return shadowContainer.layer.shadowRadius > 0 }
        set { shadowContainer.layer.shadowRadius = newValue ? 5 : 0 }
    }

    /// The shadow color
    public dynamic var shadowColor: UIColor? {
        get {
            guard let color = shadowContainer.layer.shadowColor else {
                return nil
            }
            return UIColor(cgColor: color)
        }
        set { shadowContainer.layer.shadowColor = newValue?.cgColor }
    }

    // MARK: - Views

    /// The shadow container is the basic view of the PopupDialog
    /// As it does not clip subviews, a shadow can be applied to it
    internal lazy var shadowContainer: UIView = {
        let shadowContainer = UIView(frame: .zero)
        shadowContainer.translatesAutoresizingMaskIntoConstraints = false
        shadowContainer.backgroundColor = UIColor.white
        shadowContainer.layer.shadowColor = UIColor.black.cgColor
        shadowContainer.layer.shadowRadius = 5
        shadowContainer.layer.shadowOpacity = 0.4
        shadowContainer.layer.shadowOffset = CGSize(width: 0, height: 0)
        shadowContainer.layer.cornerRadius = 16
        return shadowContainer
    }()

    /// The container view is a child of shadowContainer and contains
    /// all other views. It clips to bounds so cornerRadius can be set
    
    private var _container : UIView!
    
    public var container: UIView {
        
        get{
            if _container == nil {
                _container = UIView(frame: .zero)
                _container.translatesAutoresizingMaskIntoConstraints = false
                _container.backgroundColor = UIColor.white
                _container.clipsToBounds = true
                _container.layer.cornerRadius = 16
            }
            
            return _container
        }
    }

    // The container stack view for buttons
    internal lazy var buttonStackView: UIStackView = {
        let buttonStackView = UIStackView()
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = 0
        return buttonStackView
    }()

    // The main stack view, containing all relevant views
    private var _stackView : UIStackView!
    
    public var stackView: UIStackView  {
        get {
            
            if _stackView == nil {
                _stackView = UIStackView(arrangedSubviews: [self.buttonStackView])
                _stackView.translatesAutoresizingMaskIntoConstraints = false
                _stackView.axis = .vertical
                _stackView.spacing = 0
                
            }
            return _stackView
        }
    }

    // MARK: - Constraints

    /// The center constraint of the shadow container
    internal var centerYConstraint: NSLayoutConstraint? = nil

    // MARK: - Initializers

    internal override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View setup

    internal func setupViews() {

        // Add views
        addSubview(shadowContainer)
        shadowContainer.addSubview(container)
        container.addSubview(stackView)

        // Layout views
        let views = ["shadowContainer": shadowContainer, "container": container, "stackView": stackView]
        var constraints = [NSLayoutConstraint]()

        container.backgroundColor = UIColor.clear
        
        // Shadow container constraints
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:[shadowContainer(<=340)]", options: [], metrics: nil, views: views)
        
        widthConstraint = shadowContainer.widthAnchor.constraint(lessThanOrEqualTo: self.widthAnchor, multiplier: 1, constant: -(padding*2))
        
        widthConstraint.priority = 900
        
        leadingConstraint = shadowContainer.leadingAnchor.constraint(equalTo: shadowContainer.superview!.leadingAnchor, constant: 20)
        leadingConstraint.priority = 800
        
        trailingConstraint = shadowContainer.trailingAnchor.constraint(equalTo: shadowContainer.superview!.trailingAnchor, constant: 20)
        
        trailingConstraint.priority = 800
        
        constraints += [widthConstraint, leadingConstraint, trailingConstraint]
        
        
        constraints += [NSLayoutConstraint(item: shadowContainer, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)]
        centerYConstraint = NSLayoutConstraint(item: shadowContainer, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
        constraints.append(centerYConstraint!)

        // Container constraints
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[container]|", options: [], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|[container]|", options: [], metrics: nil, views: views)

        // Main stack view constraints
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[stackView]|", options: [], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|[stackView]|", options: [], metrics: nil, views: views)

        // Activate constraints
        NSLayoutConstraint.activate(constraints)
    }
}
