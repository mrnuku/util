//
//  NSDictionary+TableViewIndexPath.h
//  util
//
//  Created by Bálint Róbert on 31/03/16.
//  Copyright © 2016 mrnuku. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (TableViewIndexPath)

/** compute the maximum number of sections
 * @return NSInteger with the result
 */
- (NSInteger)numberOfUniqueSections;

/** compute the maximum number of rows in the given section
 * @param section the section index
 * @return NSInteger with the result
 */
- (NSInteger)numberOfRowsInSection:(NSInteger)section;

@end

@interface NSMutableDictionary (TableViewIndexPath)

/** merge an array of objects as a new section
 * @param array the source for the new section data
 */
- (void)addArrayAsNewSection:(NSArray *)array;

/** remove an indexPath from the data and handle the preceding indicies to be updated
 * @param indexPath the index path to be removed
 * @return BOOL with the resulting objects
 */
- (BOOL)removeIndexPath:(NSIndexPath *)indexPath;

@end

// USAGE EXAMPLE
#if 0

#import "ViewController.h"
#import "SimpleButtonTableViewCell.h"
#import "NSDictionary+NSIndexPath.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController {
    NSMutableDictionary *_data;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _data = [NSMutableDictionary new];
    
    NSMutableArray *temp = [NSMutableArray new];
    
    NSInteger j =  + arc4random_uniform(16);
    for (NSInteger i = 0; i < 32 + j; i++) {
        NSString *str = [NSString stringWithFormat:@"Section %li : Row %li", 0L, (long)i];
        [temp addObject:str];
    }
    [_data addArrayAsNewSection:temp];
    
    [temp removeAllObjects];
    j =  + arc4random_uniform(16);
    for (NSInteger i = 0; i < 32 + j; i++) {
        NSString *str = [NSString stringWithFormat:@"Section %li : Row %li", 1L, (long)i];
        [temp addObject:str];
    }
    [_data addArrayAsNewSection:temp];
    
    [temp removeAllObjects];
    j =  + arc4random_uniform(16);
    for (NSInteger i = 0; i < 32 + j; i++) {
        NSString *str = [NSString stringWithFormat:@"Section %li : Row %li", 2L, (long)i];
        [temp addObject:str];
    }
    [_data addArrayAsNewSection:temp];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_data numberOfUniqueSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_data numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SimpleButtonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"simpleButtonCell"];
    NSString *nodeData = [_data objectForKey:indexPath];
    
    cell.stuffLabel.text = nodeData;
    
    [cell setRemoveHandler:^(SimpleButtonTableViewCell *sender) {
        NSIndexPath *indexPath2 = [tableView indexPathForCell:sender];
        BOOL lastPathInSection = [_data removeIndexPath:indexPath2];
        
        if (!lastPathInSection) {
            [tableView deleteRowsAtIndexPaths:@[indexPath2] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else {
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath2.section] withRowAnimation:UITableViewRowAnimationFade];
        }
    }];
    
    return cell;
}

@end

// SUPLEMENT CODE: SimpleButtonTableViewCell.h, SimpleButtonTableViewCell.m

@interface SimpleButtonTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *stuffLabel;
@property (nonatomic, copy) void (^removeHandler)(SimpleButtonTableViewCell *sender);

@end

@implementation SimpleButtonTableViewCell

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.removeHandler = nil;
}

- (IBAction)removeTouchUpInside:(id)sender {
    if (self.removeHandler) {
        self.removeHandler(self);
    }
    
    self.removeHandler = nil;
}

@end

#endif
