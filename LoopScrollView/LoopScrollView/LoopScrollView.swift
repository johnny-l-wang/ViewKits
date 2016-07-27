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
    private  var view:UIView?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func attach(indexOfView:Int,view:UIView){
        if self.view != nil{
            self.view?.removeFromSuperview()
        }
        self.view=view;
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
    
    private var scale:(widthScale:CGFloat,heightScale:CGFloat)=(widthScale:0.6,heightScale:1)
    private var contentSize:CGSize!
    private var contentSpace:CGFloat!
    private var contentDistance:CGFloat!
    private var contents:[UIView]=[]
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
            moveCard(Direction.Right)
        case UISwipeGestureRecognizerDirection.Left:
            moveCard(Direction.Left)
        default:
            return
        }
    }

    private func moveCard(direction:Direction){
        
        //preloadView(direction)
        
        let moveAnimation = CABasicAnimation(keyPath: "position.x")
        moveAnimation.fillMode = kCAFillModeBoth
        moveAnimation.duration = 0.3
        
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fillMode = kCAFillModeBoth
        scaleAnimation.duration = 0.3
        
        let distance = direction == .Right ? self.contentDistance : -self.contentDistance
        
        for index in 0..<self.contents.count {
            let card = self.contents[index]
            
            let from = card.frame.origin.x + self.contentSize.width * 0.5
            moveAnimation.fromValue = from
            moveAnimation.toValue = from + distance
            
            card.layer.addAnimation(moveAnimation, forKey: "MoveCard")
            card.layer.position.x = from + distance
            
            if index == 1 {
                scaleAnimation.fromValue = 1
                scaleAnimation.toValue = 0.8
                card.transform = CGAffineTransformMakeScale(1,0.8)
            }
            else{
                scaleAnimation.fromValue = 0.8
                scaleAnimation.toValue = 1
                card.transform = CGAffineTransformMakeScale(1,1)
            }
            
            card.layer.addAnimation(scaleAnimation, forKey: "ScaleCard")
        }
        
        switch direction {
        case .Right:
            //move the last card to first
            self.contents[self.contents.count - 1].layer.position.x = self.contents[0].layer.position.x-self.contentDistance
        case .Left:
            //move the first card to last
            self.contents[0].layer.position.x = self.contents[self.contents.count - 1].layer.position.x+self.contentDistance
        }
        
        self.currentIndex=nextIndex(self.currentIndex, direction: direction)
        self.contents[self.contents.count - 1].transform = CGAffineTransformMakeScale(1,0.8)
        
        resort()
    }

//    override func drawRect(rect: CGRect) {
//       
//    }
    
    func load(index:Int=0) {
        initUI(self.frame)
        
        self.currentIndex = index;
        
        var indexOfView = index;
        
        for index in 0..<self.contents.count {
            if let datasource = self.datasource {
                if index == 0 {
                    indexOfView = self.preIndex(indexOfView, direction: .Left)
                }
                else{
                    indexOfView = self.nextIndex(indexOfView, direction: .Left)
                }
                self.contents[index].addSubview(datasource.loopScrollView(self.contentSize,indexOfView: indexOfView))
            }
        }
    }
    
    private func initUI(frame: CGRect) {
        self.contents = []
        self.contentSize = CGSizeMake(frame.width*self.scale.widthScale, frame.height*self.scale.heightScale)
        self.contentSpace = frame.width*(1-self.scale.widthScale)/4
        self.contentDistance = self.contentSpace + self.contentSize.width
        
        print("self.frame=\(frame)")
        print("self.contentSize=\(self.contentSize)")
        print("self.contentSpace=\(self.contentSpace)")
        
        var x:CGFloat = 0 - self.contentSize.width + self.contentSpace
        
        for _ in 0...3 {
            let view=UIView(frame: CGRectMake(x,0,self.contentSize.width,self.contentSize.height))
            view.backgroundColor=UIColor.clearColor()
            self.contents.append(view)
            self.addSubview(view)
            
            x += self.contentDistance
        }
    }
    
    private func nextIndex(currentIndex:Int,direction:Direction )->Int{
        var nextIndex:Int=0
        
        switch direction {
        case .Right:
            nextIndex = currentIndex - 1 < 0 ? self.count - 1 : currentIndex - 1
        case .Left:
            nextIndex = currentIndex + 1 == self.count ? 0 : currentIndex + 1
        }
        
        return nextIndex
    }
    
    private func preIndex(currentIndex:Int,direction:Direction)->Int{
        var preIndex:Int=0
        
        switch direction {
        case .Right:
            preIndex = currentIndex + 1 == self.count ? 0 : currentIndex + 1
        case .Left:
            preIndex = currentIndex - 1 < 0 ? self.count - 1 : currentIndex - 1
        }
        
        return preIndex
    }
    
    private func resort(){
        self.contents = self.contents.sort{ $0.layer.position.x < $1.layer.position.x }
    }
}
