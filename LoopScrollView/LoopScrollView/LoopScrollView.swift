//
//  LoopScrollView.swift
//  LoopScrollView
//
//  Created by Johnny L Wang on 16/7/26.
//  Copyright © 2016 IDI Studio. All rights reserved.
//

import UIKit

public protocol LoopScrollViewDataSource:NSObjectProtocol {
    func loopScrollView(size:CGSize,indexOfView:Int) -> UIView
    func loopScrollViewCount() -> Int
}

internal class ContentView:UIView {
    
    private var indexOfView:Int?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func attach(indexOfView:Int,view:UIView){
        if self.subviews.count>0 {
            self.subviews[0].removeFromSuperview()
        }
        self.indexOfView=indexOfView
        self.addSubview(view)
    }
}

@IBDesignable public class LoopScrollView: UIView {

    var currentIndex:Int=0
    var datasource:LoopScrollViewDataSource?
    
    enum Direction {
        case Left
        case Right
    }
    
    private var scale:(widthScale:CGFloat,heightScale:CGFloat)=(widthScale:0.65,heightScale:0.8)
    private var contentSize:CGSize!
    private var contentSpace:CGFloat!
    private var contentDistance:CGFloat!
    private var contents:[ContentView]=[]
    private var count:Int{
        get{
            if let datasource = self.datasource {
                return datasource.loopScrollViewCount()
            }
            
            return 0
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        //右划手势
        let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(LoopScrollView.handleSwipeGesture(_:)) )
        swipeRightGesture.direction = UISwipeGestureRecognizerDirection.Right
        self.addGestureRecognizer(swipeRightGesture)
        
        //左划手势
        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(LoopScrollView.handleSwipeGesture(_:)))
        swipeLeftGesture.direction = UISwipeGestureRecognizerDirection.Left
        self.addGestureRecognizer(swipeLeftGesture)
    }
    
    func handleSwipeGesture(sender: UISwipeGestureRecognizer){
        switch sender.direction {
        case UISwipeGestureRecognizerDirection.Right:
            move(Direction.Right)
        case UISwipeGestureRecognizerDirection.Left:
            move(Direction.Left)
        default:
            return
        }
    }

    private func move(direction:Direction){
        if self.count==0 || self.contents.count==0 {
            print("self.count=\(self.count)")
            print("self.contents.count=\(self.contents.count)")
            return
        }
        
        preload(direction)
        
        let moveAnimation = CABasicAnimation(keyPath: "position.x")
        moveAnimation.fillMode = kCAFillModeBoth
        moveAnimation.duration = 0.3
        
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fillMode = kCAFillModeBoth
        scaleAnimation.duration = 0.3
        
        let distance = direction == .Right ? self.contentDistance : -self.contentDistance
        
        for index in 0..<self.contents.count {
            let content = self.contents[index]
            
            let from = content.frame.origin.x + self.contentSize.width * 0.5
            moveAnimation.fromValue = from
            moveAnimation.toValue = from + distance
            
            content.layer.addAnimation(moveAnimation, forKey: "MoveCard")
            content.layer.position.x = from + distance
            
            if index == 1 {
                scaleAnimation.fromValue = 1
                scaleAnimation.toValue = 0.8
                content.transform = CGAffineTransformMakeScale(1,0.8)
            }
            else{
                scaleAnimation.fromValue = 0.8
                scaleAnimation.toValue = 1
                content.transform = CGAffineTransformMakeScale(1,1)
            }
            
            content.layer.addAnimation(scaleAnimation, forKey: "ScaleCard")
        }
        
        switch direction {
        case .Right:
            //move the last card to first
            self.contents[self.contents.count - 1].layer.position.x = self.contents[0].layer.position.x-self.contentDistance
        case .Left:
            //move the first card to last
            self.contents[0].layer.position.x = self.contents[self.contents.count - 1].layer.position.x+self.contentDistance
        }
        
        self.contents[self.contents.count - 1].transform = CGAffineTransformMakeScale(1,0.8)
        self.contents = self.contents.sort{ $0.layer.position.x < $1.layer.position.x }
    }
    
    private func preload(direction:Direction){
        if var indexOfView = self.contents[3].indexOfView {
            switch direction {
            case .Right:
                indexOfView=preIndex(self.contents[0].indexOfView!)
            case .Left:
                indexOfView=nextIndex(self.contents[2].indexOfView!)
            }
            
            if let datasource = self.datasource {
                let view=datasource.loopScrollView(self.contentSize, indexOfView: indexOfView)
                self.contents[3].attach(indexOfView, view: view)
            }
        }
    }
    
    private func load(index:Int=0) {
        initUI(self.frame)
        
        //print("self.frame=\(self.frame)")
        
        var indexOfView = 0;
        
        if index >= self.count {
            self.currentIndex = 0;
        }
        else{
            self.currentIndex = preIndex(index);
            indexOfView = preIndex(index);
        }
        
        for index in 0..<self.contents.count {
            if let datasource = self.datasource {
                if index>0 {
                    indexOfView = self.nextIndex(indexOfView)
                }
                print("load:\(indexOfView)")
                self.contents[index].attach(indexOfView, view: datasource.loopScrollView(self.contentSize,indexOfView: indexOfView))
            }
        }
    }
    
    override public func drawRect(rect: CGRect) {
        initUI(rect)
        load(self.currentIndex)
    }
    
    private func initUI(frame: CGRect) {
        for view in self.subviews{
            view.removeFromSuperview()
        }
        
        self.contents=[]
        self.contentSize = CGSizeMake(frame.width*self.scale.widthScale, frame.height*self.scale.heightScale)
        self.contentSpace = frame.width*(1-self.scale.widthScale)/4
        self.contentDistance = self.contentSpace + self.contentSize.width
        
        var x:CGFloat = 0 - self.contentSize.width + self.contentSpace
        
        for _ in 0...3 {
            let content=ContentView(frame: CGRectMake(x,0,self.contentSize.width,self.contentSize.height))
            content.backgroundColor=UIColor.clearColor()
            self.contents.append(content)
            self.addSubview(content)
            x += self.contentDistance
        }
        
        self.contents[0].transform = CGAffineTransformMakeScale(1,0.8)
        self.contents[2].transform = CGAffineTransformMakeScale(1,0.8)
    }
    
    private func nextIndex(currentIndex:Int)->Int{
        return (currentIndex + 1 == self.count) ? 0 : currentIndex + 1
    }
    
    private func preIndex(currentIndex:Int)->Int{
        return (currentIndex - 1 < 0) ? self.count - 1 : currentIndex - 1
    }
}
