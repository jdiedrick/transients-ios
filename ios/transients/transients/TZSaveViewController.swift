//
//  TZSaveViewController.swift
//  transients
//
//  Created by Jason Sigal on 8/4/15.
//  Copyright (c) 2015 Johann Diedrick. All rights reserved.
//

import Foundation
import UIKit

class TZSaveViewController: UIViewController{
    
    
    /**
        variables:
            - the file location / duration

        on this screen:
            - update location
            - text box: description, tags
            - display time and date
    **/
    
    var file_path:NSURL?
    
    var title_box:UITextField?
    var description_box:UITextField?
    var tag_box:UITextField?

    
    var location_label:UILabel?
    var time_label:UILabel?
    var date_label:UILabel?


    
    override func viewDidLoad(){
        super.viewDidLoad()

        view.backgroundColor = UIColor.grayColor()
        
        title_box = UITextField()
        title_box?.setTranslatesAutoresizingMaskIntoConstraints(false)
        title_box?.backgroundColor = UIColor.purpleColor()
        title_box?.placeholder = "Title of Sound (optional)"
        
        description_box = UITextField()
        description_box?.setTranslatesAutoresizingMaskIntoConstraints(false)
        description_box?.backgroundColor = UIColor.yellowColor()
        description_box?.placeholder = "Description (optional)"

        let viewsDictionary = ["title_box":title_box!,"description_box":description_box!]

        
        self.view.addSubview(title_box!)
        self.view.addSubview(description_box!)
        
        //position constraints

        /** test **/
        //Make a view


        //sizing constraints
        // thx http://makeapppie.com/2014/07/26/the-swift-swift-tutorial-how-to-use-uiviews-with-auto-layout-programmatically/

        let view_constraint_H:NSArray = NSLayoutConstraint.constraintsWithVisualFormat("H:|-36-[description_box]-|", options: NSLayoutFormatOptions.AlignAllCenterY, metrics: nil, views: viewsDictionary)
        let view_constraint_V:NSArray = NSLayoutConstraint.constraintsWithVisualFormat("V:|-[title_box]-[description_box]-|", options: NSLayoutFormatOptions.AlignAllLeading, metrics: nil, views: viewsDictionary)
        
        view.addConstraints(view_constraint_H as [AnyObject])
        view.addConstraints(view_constraint_V as [AnyObject])
        
    }
    
    
}