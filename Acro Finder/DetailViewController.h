//
//  DetailViewController.h
//  Acro Finder
//
//  Created by Sai Gogineni on 1/18/16.
//  Copyright (c) 2016 Sai Gogineni. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

