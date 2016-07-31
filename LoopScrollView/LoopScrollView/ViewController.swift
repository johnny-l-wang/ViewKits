//
//  ViewController.swift
//  LoopScrollView
//
//  Created by Johnny L Wang on 16/7/26.
//  Copyright © 2016 IDI Studio. All rights reserved.
//

import UIKit

class ViewController: UIViewController,LoopScrollViewDataSource {

    @IBOutlet weak var loopscrollview: LoopScrollView!
    
    private let colors:[UIColor]=[UIColor.redColor(),UIColor.orangeColor(),UIColor.yellowColor(),UIColor.greenColor(),UIColor.blueColor()]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loopscrollview.datasource=self
        self.loopscrollview.load(4)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func loopScrollView(size: CGSize, indexOfView: Int) -> UIView {
        let view=UIView(frame: CGRectMake(0,0,size.width,size.height))
        view.backgroundColor=colors[indexOfView]
        
        let label=UILabel(frame: CGRectMake(0,0,size.width,size.height))
        label.text="\(indexOfView+1)"
        label.textAlignment = .Center
        
        view.addSubview(label)

        return view
    }
    
    func loopScrollViewCount() -> Int {
        return self.colors.count
    }

}

