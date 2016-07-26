//
//  LoopScrollView.swift
//  LoopScrollView
//
//  Created by Johnny L Wang on 16/7/26.
//  Copyright © 2016 IDI Studio. All rights reserved.
//

import UIKit

protocol LoopScrollViewDataSource:NSObjectProtocol {
    func loopScrollView(size:CGSize,indexOfView:Int) -> UIView
    func loopScrollViewCount() -> Int
}

@IBDesignable class LoopScrollView: UIView {

    var currentIndex:Int=0
    var datasource:LoopScrollViewDataSource?
    
    enum Direction {
        case Left
        case Right
    }
    
    private var scale:(widthScale:CGFloat,heightScale:CGFloat)=(widthScale:0.6,heightScale:1)
    private var contentSize:CGSize!
    private var contentSpace:CGFloat!
    private var contents:[UIView]!
    private var count:Int{
        get{
            if let datasource = self.datasource {
                return datasource.loopScrollViewCount()
            }
            
            return 0
        }
    }
    
    override func drawRect(rect: CGRect) {
        self.contents = []
        self.contentSize = CGSizeMake(rect.width*self.scale.widthScale, rect.height*self.scale.heightScale)
        
        for _ in 0...3{
            let view=UIView(frame: CGRectMake(0,0,self.contentSize.width,self.contentSize.height))
            view.backgroundColor=UIColor.clearColor()
            self.contents.append(view)
        }
    }
    
    func load(index:Int=0) {
        self.currentIndex = index;
        
        var indexOfView = index;
        
        for index in 0..<contents.count {
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
}
