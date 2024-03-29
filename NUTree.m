//
//  NUTree.m
//  NUTree
//
//  Created by . Carlin on 10/16/13.
//  Copyright (c) 2013 Carlin Creations. All rights reserved.
//

#import "NUTree.h"

#define DEFAULT_NODE_CAPACITY 3 // Must be > 2, or can't split branches properly

#pragma mark - NUTreeNode

@implementation NUTreeNode

- (id)init
{
    self = [super init];
    if (self) {
        _data = [NSMutableArray new];
        _children = [NSMutableArray new]; 
    }
    return self;
}

/** @brief Initialize with parent node */
- (id)initWithParent:(NUTreeNode *)parent
{
    self = [super init];
    if (self) {
        _parent = parent;
        _data = [NSMutableArray new];
        _children = [NSMutableArray new];  
    }
    return self;
}

/** @brief Get index of node in children array */
- (NSUInteger)indexOfChildNode:(NUTreeNode *)child
{
    return [self.children indexOfObject:child];
    
    // Binary search method
//    [self.children indexOfObject:child 
//                          inSortedRange:NSMakeRange(0, self.children.count) 
//                                options:NSBinarySearchingFirstEqual
//                        usingComparator:^NSComparisonResult(id obj1, id obj2) {
//                            NUTreeNode *n1 = (NUTreeNode *)obj1;
//                            NUTreeNode *n2 = (NUTreeNode *)obj2; 
//                            if (n1 == n2) {
//                                return NSOrderedSame;
//                            } else {
//                                return [n1.data[0] compare:n2.data[0]];
//                            } 
//                        }];
}

/** @brief Get index of object in data array */
- (NSUInteger)indexOfDataObject:(id)object
{
    return [self.data indexOfObject:object 
        inSortedRange:NSMakeRange(0, self.data.count) 
        options:NSBinarySearchingFirstEqual
        usingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj1 compare:obj2];
        }];
}

/** @brief Print entire tree */
- (NSString *)printTree
{
    return [self printTreeNode:self indent:1];
}

- (NSString *)printTreeNode:(NUTreeNode *)node indent:(int)indent
{
    // Build indent
    NSMutableString *padding = [NSMutableString new];
    for (int i = 0; i < indent; ++i) {
        [padding appendString:@"\t"];
    }
    
    // Build string
    NSMutableString *string = [[node description] mutableCopy];
    for (NUTreeNode *child in node.children) {
        [string appendString:[NSString stringWithFormat:@"\n%@%@", 
            padding, [self printTreeNode:child indent:indent + 1]]];
    }
    
    return string;
}

/** @brief Prints and checks for pointer discrepancies in children, returns YES if all children have appropriate pointers to each other and their parent. Does not include the childrens' children. */
- (BOOL)hasValidPointerStructure
{
    BOOL valid = YES;
    NUTreeNode *current, *next;
    
    // Trivial case
    if (!self.children.count) {
        return YES;
    }
    
    // Iterate through children and check pointers
    for (int i = 0; i < self.children.count; ++i)
    {
        current = self.children[i];  
               
        if (current.parent != self) {
            valid = NO;
            NSLog(@"Child with wrong parent pointer: %@", current);
        }
        
        if (i + i < self.children.count) {
            next = self.children[i + 1];  
            if (next.previous != current
                || current.next != next) {
                valid = NO;
                NSLog(@"Siblings with wrong pointers: %@ <-> %@", current, next);
            }
        }
    }
    
    return valid;
}

- (NSString *)description 
{
    return [NSString stringWithFormat:@"%p: %@", self, [[self.data valueForKey:@"description"] componentsJoinedByString:@", "]];
}

- (id)copyWithZone:(NSZone *)zone
{
    id copy = [[[self class] alloc] init];
    
    if (copy) {
        [copy setData:[self.data copyWithZone:zone]]; 
        [copy setChildren:[self.children copyWithZone:zone]];  
    }
    
    return copy;
}

@end


#pragma mark - NUTree

@interface NUTree()
    @property (nonatomic, strong) NUTreeNode *root;
    @property (nonatomic, assign) NSInteger nodeMinimum;
    @property (nonatomic, assign, readwrite) NSInteger nodeCapacity;
    @property (nonatomic, assign, readwrite) NSInteger count;
    
    // Cache and flag for quick access
    @property (nonatomic, assign, readwrite) BOOL cacheOutdated; 
    @property (nonatomic, strong) NSArray *cache;
    
    // Fast enumeration
    @property (nonatomic, assign) BOOL fastEnumerating;  
@end


@implementation NUTree


#pragma mark - Constructors

- (id)init
{
    self = [super init];
    if (self) {
        _nodeCapacity = DEFAULT_NODE_CAPACITY;
        _nodeMinimum = _nodeCapacity / 2;
        _cacheOutdated = NO;
        _fastEnumerating = NO; 
        _root = [NUTreeNode new];
    }
    return self;
}

/** @brief Create tree with a certain number of allowable children */
- (id)initWithNodeCapacity:(NSUInteger)nodeCapacity
{
    self = [super init];
    if (self) {
        _nodeCapacity = MAX(nodeCapacity, DEFAULT_NODE_CAPACITY);
        _nodeMinimum = _nodeCapacity / 2; 
        _cacheOutdated = NO; 
        _fastEnumerating = NO; 
        _root = [NUTreeNode new]; 
    }
    return self;
}

/** @brief Create tree with a certain number of allowable children using the given array of objects as its base data */
- (id)initWithNodeCapacity:(NSUInteger)nodeCapacity withSortedObjects:(NSArray *)data
{
    self = [super init];
    if (self) {
        _nodeCapacity = MAX(nodeCapacity, DEFAULT_NODE_CAPACITY);
        _nodeMinimum = _nodeCapacity / 2; 
        _cacheOutdated = NO;  
        _fastEnumerating = NO; 
        _root = [self buildTreeWithNodeCapacity:_nodeCapacity withSortedObjects:data];
        _count = data.count;
    }
    return self;
}

/** @brief Description when printed using NSLog */
- (NSString *)description 
{
    return [self printTree];    // Print whole tree
}

/** @brief Construct tree by bulkloading given array of object data
    @param data NSArray of objects, must be sorted. 
    @return NUTreeNode * Root of data tree.
*/
- (NUTreeNode *)buildTreeWithNodeCapacity:(NSUInteger)nodeCapacity withSortedObjects:(NSArray *)data
{
    NSMutableArray *children = [NSMutableArray new];
    NSMutableArray *parents = [NSMutableArray new]; 
    NUTreeNode *child, *parent, *prev;
    
    // Create leaves
    for (NSUInteger i = 0; i < data.count; ) 
    {
        // Create new leaf node, set pointers
        child = [NUTreeNode new];
        if (prev) {
            child.previous = prev;
            prev.next = child;
        }
        prev = child;   // update previous
        
        // Fill it with max capacity + 1 data, except for last node
        NSUInteger fillCount = nodeCapacity 
            + (data.count - i > nodeCapacity + 1 ? 1 : 0);
        for (NSUInteger j = 0; j < fillCount && i < data.count; ++j, ++i) {
            [child.data addObject:data[i]];
        }
        
        // Add child to array
        [children addObject:child];
    }
    
    // Build rest of tree from leaves
    while (children.count > 1)
    {
//        NSLog(@"CHILDREN: \n%@", children);
    
        // Setup for next level
        [parents removeAllObjects];
        prev = nil; 
        
        // Create parents using children
        for (NSUInteger i = 0; i < children.count - 1; )
        {
            // Create parent node, set pointers
            parent = [NUTreeNode new];
            if (prev) {
                parent.previous = prev; 
                prev.next = parent;
            }
            prev = parent;  // update previous
            
            // Fill it with data & children
            NSUInteger fillCount = nodeCapacity 
                + (children.count - i > nodeCapacity + 1 ? 1 : 0); 
            for (NSUInteger j = 0; j < fillCount && i < children.count - 1; ++j, ++i) 
            {
                child = children[i];  
                NSUInteger index = child.data.count - 1;
                               
                // Add child
                [parent.children addObject:child];
                child.parent = parent; 
                
                // Add data from end of child
                [parent.data addObject:child.data[index]];
                [child.data removeObjectAtIndex:index];
            }
            
            // Add last child
            if (i == children.count - 1)
            {
                child = children[i];
                [parent.children addObject:child];
                child.parent = parent;  
            }
            
            // Add parent to array
            [parents addObject:parent];
        }
        
        children = parents;
    }

    return children[0];
}


#pragma mark - Public Methods

/** @brief Add object to tree, YES if successful */
- (BOOL)addObject:(id)object
{
    if (!object) {
        return NO;
    }
    
    if ([self addObject:object withChild:nil toNode:
         [self getLeafNodeForObject:object inNode:self.root]]) {
        self.count++;
        self.cacheOutdated = YES;
        return YES;
    }
    return NO;
}

/** @brief Remove object from tree, returns NO if not in tree */
- (BOOL)removeObject:(id)object
{
    if (!object || self.root.data.count <= 0) {
        return NO;
    }
    
    if ([self removeObject:object fromNode:
         [self getFirstNodeThatContains:object inBranch:self.root]]) {
        self.count--;
        self.cacheOutdated = YES; 
        return YES;
    }
    return NO;
}

/** @brief Search for object in tree, returns NO if not found */
- (BOOL)containsObject:(id)object
{
    if (!object || self.root.data.count <= 0) {
        return NO;
    }
    
    return ([self getFirstNodeThatContains:object inBranch:self.root] != nil); 
}

/** @brief Returns YES if tree is empty */
- (BOOL)isEmpty
{
    return (self.root.data.count == 0);
}

/** @brief Returns minimum element, or nil if none */
- (id)minimum
{
    if (self.root.data.count) {
        NUTreeNode *node = [self getLeftMostNode:self.root];
        if (node.data && node.data.count) {
            return [node.data objectAtIndex:0];
        } else {
            NSLog(@"Warning! Non-root node with empty data!");
        }
    }
    
    return nil;
}

/** @brief Returns maximum element, or nil if none */
- (id)maximum
{
    if (self.root.data.count) {
        NSArray *data = [[self getRightMostNode:self.root] data];
        return [data objectAtIndex:data.count - 1]; 
    }
    
    return nil;
}

/** @brief Returns sorted array of tree contents */
- (NSArray *)toArray
{
    // Check cache & rebuild if necessary
    if (!self.cache || self.cacheOutdated) {
        [self rebuildCache];
    } 
    
    return self.cache;
}

/** @brief Rebuild cache for fast access, returns NO if cache could not be refreshed (probably due to someone iterating over it) */
- (BOOL)rebuildCache
{
    // Don't rebuild cache if fast enumerating
    if (self.fastEnumerating) {
        return NO;
    }
    
    NSMutableArray *storage = [NSMutableArray new];
    
    // Traverse and add data into array in order
    [self traverse:^BOOL(NUTreeNode *node, id data, id extra) {
            [(NSMutableArray *)extra addObject:data];
            return YES;
        } 
        extraData:storage 
        onTree:self.root 
        withAlgorithm:NUTreeTraverseAlgorithmInorder];
    
    // Set cache, clear flag
    self.cache = storage;
    self.cacheOutdated = NO;
    
    return YES;
}

/** @brief Returns number of elements in tree */
- (NSUInteger)trueCount
{
    static NSString *KEY_COUNT = @"total";
    
    if (self.root.data.count) {
        NSMutableDictionary *extra = [@{
            KEY_COUNT: [NSNumber numberWithInt:0]
        } mutableCopy];
        [self traverse:^BOOL(NUTreeNode *node, id data, id extra) {
                extra[KEY_COUNT] = [NSNumber
                    numberWithInteger:[extra[KEY_COUNT] unsignedIntegerValue] + 1];
                return 1;
            } extraData:extra onTree:self.root 
            withAlgorithm:NUTreeTraverseAlgorithmInorder];
        return [extra[KEY_COUNT] unsignedIntegerValue];
    }
    
    return 0;
}

/** @brief Returns printout of the tree */
- (NSString *)printTree
{
    NSMutableString *result = [NSMutableString new];
    [self traverse:^BOOL(NUTreeNode *node, id data, id extra) {
            NSMutableString *padding = [NSMutableString new];
            for (NUTreeNode *parent = node.parent; parent; parent = parent.parent) {
                [padding appendString:@"\t"];
            }
            [extra appendString:[NSString stringWithFormat:@"%@%@\n", padding, data]];
            return YES;
        } extraData:result onTree:self.root 
        withAlgorithm:NUTreeTraverseAlgorithmInorder];
    
    return result;
}

/** @brief Returns object at index, or nil if none / out of bounds */
- (id)objectAtIndex:(NSUInteger)index
{
    // Insanity checks
//    if (index < 0) {
//        return nil;
//    }
   
    // Check cache & rebuild if necessary
    if (!self.cache || self.cacheOutdated) {
        [self rebuildCache];
    } 
    
    // Check index is within bounds
    if (index >= self.cache.count) {
        return nil;
    }
    
    return self.cache[index];
}

/** @brief Traverse the tree in sorted order while executing block on every element
    @param block Traversal block to be called on data as we traverse 
    @param extra User defined object that will be passed to block to help do things like aggregate calculations.
    @param algo Traversal algorithm: inorder, postorder, preorder, bfs
    @return BOOL YES if traversed through entire tree, FALSE if cut short by traversal block
*/
- (BOOL)traverse:(NUTreeTraverseBlock)block 
       extraData:(id)extra 
   withAlgorithm:(NUTreeTraverseAlgorithm)algo
{
   return [self traverse:block extraData:extra onTree:self.root withAlgorithm:algo]; 
}


#pragma mark - Tree Methods

/** @brief Adds an object to a node in sorted order, with an accompanying child branch if relevant.
    @param object Object to be added.
    @param child Child branch to add to node after the data is added.
    @param node Node to add the data to.
    @return BOOL YES if adding is successful, NO if error
*/
- (BOOL)addObject:(id)object withChild:(NUTreeNode *)child toNode:(NUTreeNode *)node
{
    if (!object || !node) {
        return NO;
    }
   
    // Find index where we should put it, and add it
    NSUInteger index = [node.data indexOfObject:object 
        inSortedRange:NSMakeRange(0, node.data.count) 
        options:NSBinarySearchingInsertionIndex 
        usingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj1 compare:obj2];
        }];
    [node.data insertObject:object atIndex:index];
    
    // Add child if exists, need to add right after data insertion
    if (child) 
    {
        if (index + 1 > node.children.count) {
            NSLog(@"Warning! Adding child at index greater than children count for child: %@", child);
        }
        
        // Insert & change parent pointer
        [node.children insertObject:child atIndex:index + 1];
        child.parent = node;
        
        // Switch up sibling pointers
        NUTreeNode *sibling = node.children[index];
        if (sibling) {
            child.next = sibling.next;
            child.previous = sibling;
            child.previous.next = child;
            if (child.next) {
                child.next.previous = child;
            }
        } 
        else    // This shouldn't happen
        {
            NSLog(@"Warning! Checking next sibling pointer while adding child: %@", child);
        }
    }
    
    // Rebalance as needed
    [self rebalanceNode:node];
    
    return YES; 
}

/** @brief Removes an object from a node
    @param object Object to be removed.
    @param node Node to remove object from.
    @return BOOL YES if removed, NO if not found or if there was an error.
*/
- (BOOL)removeObject:(id)object fromNode:(NUTreeNode *)node
{
    if (!object || !node || node.data.count <= 0) {
        return NO;
    }
    
//    NSLog(@"Removing object %@ from node %@", object, node);
    
    // Get index to remove from
    NSUInteger index = [node indexOfDataObject:object];
    if (index == NSNotFound) {
        NSLog(@"Warning! Could not find index of object for removal: %@", object);
        return NO;
    }
    
    // If leaf node, simple remove
    if (!node.children.count) 
    {
        // If we use removeObject:(id) it removes all occurrences
        [node.data removeObjectAtIndex:index];
        
        // Rebalance as needed
        [self rebalanceNode:node];  
    }
    else    // Deal with replacing separator
    {
        // Replace with smallest value from right subtree
        NUTreeNode *child = [self getLeftMostNode:node.children[index + 1]];
        id replacementObject = child.data[0];
        [node.data replaceObjectAtIndex:index withObject:replacementObject];
        [child.data removeObjectAtIndex:0];
        
        // Rebalance child node if needed
        [self rebalanceNode:child];
    }
    
    return YES; 
}

/** @brief Returns the first node that contains the given object using standard comparison rules, starting from given node branch. */
- (NUTreeNode *)getFirstNodeThatContains:(id)object inBranch:(NUTreeNode *)node
{
    if (!object || !node || !node.data.count) {
        return nil;
    }
    
    // Search for item in node data
    NSUInteger index = [node.data indexOfObject:object 
        inSortedRange:NSMakeRange(0, node.data.count) 
        options:NSBinarySearchingInsertionIndex 
            | NSBinarySearchingFirstEqual
        usingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj1 compare:obj2];
        }];
    
    // If within bounds of data (note the <= count due to subtree indexing)
    if (index <= node.data.count)
    {
        // Check if item is equal at index 
        if (index < node.data.count && [node.data[index] compare:object] == NSOrderedSame) {
            return node;
        }
        
        // If has children, need to search subtree
        if (node.children.count) {
            return [self getFirstNodeThatContains:object inBranch:node.children[index]];
        }
    } 
    
    return nil;
}

/** @brief Returns the lowest node that contains the given object using standard comparison rules, starting from given node branch. */
- (NUTreeNode *)getLowestNodeThatContains:(id)object inBranch:(NUTreeNode *)node
{
    if (!object || !node || !node.data.count) {
        return nil;
    }
    
//    NSLog(@"Get: %@ in %@", object, node);
    
    // Search for item in node data
    NSUInteger index = [node.data indexOfObject:object 
        inSortedRange:NSMakeRange(0, node.data.count) 
        options:NSBinarySearchingInsertionIndex 
            | NSBinarySearchingFirstEqual
        usingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj1 compare:obj2];
        }];
    
    // If within bounds of data (note the <= count due to subtree indexing)
    if (index <= node.data.count)
    {
        // Search subtree (don't terminate early on find because it's worth finding and deleting from leaf node to prevent restructuring)
        NUTreeNode *child = nil;
        if (node.children.count) {
            child = [self getLowestNodeThatContains:object inBranch:node.children[index]];
        }
        
        // If item exists and is equal at index and no child with value exists, then use as return value
        if (index < node.data.count && [node.data[index] compare:object] == NSOrderedSame) {
            return (child) ? child : node;
        }
        
        return child;
    } 
    
    return nil;
}

/** @brief Searches for and returns the appropriate leaf node for an object to be inserted, starting from given node. */
- (NUTreeNode *)getLeafNodeForObject:(id)object inNode:(NUTreeNode *)node
{
    if (!object || !node) {
        return nil;
    }
    
    // If there are children, go farther down
    if (node.children.count)
    {
        // Search for item in node data
        NSUInteger index = [node.data indexOfObject:object 
            inSortedRange:NSMakeRange(0, node.data.count) 
            options:NSBinarySearchingInsertionIndex 
                | NSBinarySearchingFirstEqual 
            usingComparator:^NSComparisonResult(id obj1, id obj2) {
                return [obj1 compare:obj2];
            }];
        
        // If within bounds of children
        if (index < node.children.count) {
            return [self getLeafNodeForObject:object 
                                       inNode:node.children[index]];  
        } else {
            NSLog(@"Warning: could not find leaf node for object: %@", object);
            return nil;     // This shouldn't happen!
        }
    }
    else {  // Found the node
        return node;
    }
}

/** @brief Returns left-most node in tree starting from given node */
- (NUTreeNode *)getLeftMostNode:(NUTreeNode *)node
{
    while (node.children.count) {
        node = node.children[0];
    }
    
    return node;
}

/** @brief Returns right-most node in tree starting from given node */
- (NUTreeNode *)getRightMostNode:(NUTreeNode *)node
{
    while (node.children.count) {
        node = node.children[node.children.count-1];
    }
    
    return node;
}

/** @brief Traverse the tree in sorted order while executing block on every element
    @param block Traversal block to be called on data as we traverse 
    @param extra User defined object that will be passed to block to help do things like aggregate calculations.
    @param root Tree to traverse starting at given node
    @param algo Traversal algorithm: inorder, postorder, preorder, bfs
    @return BOOL YES if traversed through entire tree, FALSE if cut short by traversal block
*/
- (BOOL)traverse:(NUTreeTraverseBlock)block extraData:(id)extra onTree:(NUTreeNode *)root withAlgorithm:(NUTreeTraverseAlgorithm)algo
{
    // Return condition
    if (!root) {
        return YES;
    }
    
    // If Breadth First traversal
    if (algo == NUTreeTraverseAlgorithmBreadthFirst)
    {
        // Go through data
        for (NSUInteger i = 0; i < root.data.count; ++i) {
            if (!block(root, root.data[i], extra)) {
                return NO;   // If block cuts traversal short
            }
        } 
        
        // Go to next sibling node, or next level's leftmost node
        if (root.next) {
            if (![self traverse:block extraData:extra onTree:root.next withAlgorithm:algo]) {
                return NO;   // If block cuts traversal short 
            }
        } 
        else  // Find next level's leftmost node
        {
            // Go to leftmost node in current level
            NUTreeNode *node = root;
            while (node.previous) {
                node = node.previous;   
            }
            
            // Start traversal on it's leftmost child
            if (node.children.count) {
                if (![self traverse:block extraData:extra onTree:node.children[0] withAlgorithm:algo]) {
                    return NO;   // Traversal cut short
                }
            } else {
//                NSLog(@"End of Breadth First Traversal");
                return YES;
            }
        }
    }
    else    // Depth First traversal
    {
        if (algo == NUTreeTraverseAlgorithmPostorder) 
        {
            for (NSUInteger i = 0; i < root.children.count; ++i) {
                if (![self traverse:block extraData:extra onTree:root.children[i] withAlgorithm:algo]) {
                    return NO;   // Traversal cut short 
                }
            }
        }
      
        // Process data, note the <= count for subtree traversal
        for (NSUInteger i = 0; i <= root.data.count; ++i)
        {
            // Process subtrees in order
            if (algo == NUTreeTraverseAlgorithmInorder &&
                i < root.children.count &&
                ![self traverse:block extraData:extra onTree:root.children[i] withAlgorithm:algo])
            {
                return NO;   // Traversal cut short
            }
            
            // Process data in order
            if (i < root.data.count && !block(root, root.data[i], extra))
            {
                return NO;   // Traversal cut short
            }
        }
      
        if (algo == NUTreeTraverseAlgorithmPreorder) 
        {
            for (NSUInteger i = 0; i < root.children.count; ++i) {
                if (![self traverse:block extraData:extra onTree:root.children[i] withAlgorithm:algo]) {
                    return NO;   // Traversal cut short    
                }
            }
        }
    }
    
    return YES;    // Made it through traversal
}

- (void)rebalanceNode:(NUTreeNode *)node
{
//    NSLog(@"Tree State: \n%@", [self printTree]);  
        
    // If node is at capacity, need to split
    if (node.data.count > self.nodeCapacity)
    {
//        NSLog(@"Rebalance Node with Max Capacity: %@", node);

        // Create right node to be efficient about removing from arrays
        NUTreeNode *newRightNode = [[NUTreeNode alloc] initWithParent:node.parent];
        NSUInteger middle = node.data.count / 2;
        NSUInteger childIndex = middle + 1;
        id object = node.data[middle];

        // Iterate through data & children from middle + 1 and add to new node
        for (NSUInteger i = childIndex; i < node.data.count; ++i) {
            [newRightNode.data addObject:node.data[i]];
        }
        for (NSUInteger i = childIndex; i < node.children.count; ++i) {
            [newRightNode.children addObject:node.children[i]];
            [node.children[i] setParent:newRightNode]; 
        } 

        // Remove old items from left node, including middle item
        [node.data removeObjectsInRange:
            NSMakeRange(middle, node.data.count - middle)];

        // Remove old children from left node if exists, including middle
        if (node.children.count) {
            [node.children removeObjectsInRange:
                NSMakeRange(childIndex, node.children.count - childIndex)]; 
        }
        
        // Add to parent, if exists
        if (node.parent) {
            [self addObject:object withChild:newRightNode toNode:node.parent];
        }
        else if (node == self.root)    // Root node, need to create new root
        {
            NUTreeNode *newRootNode = [NUTreeNode new];
            
            // Set current node's new parent, add as child to new parent
            node.parent = newRootNode;
            [newRootNode.children addObject:node];
                       
            // Set new root
            self.root = newRootNode; 
            
            // Add data and new right branch to new parent
            [self addObject:object withChild:newRightNode toNode:newRootNode];
        }
        else {
            // This shouldn't happen
            NSLog(@"Warning! Rebalancing node that doesn't have a parent and isn't the root!");
        }
    }

    // If node is below min capacity (and not the root), need to join
    else if (node != self.root && node.data.count < self.nodeMinimum)
    {
//        NSLog(@"Rebalance Node with Min Capacity: %@", node); 
           
        // If right sibling has more than min elements, rotate left
        if (node.next && node.next.parent == node.parent
            && node.next.data.count > self.nodeMinimum) {
            [self rotateNode:node toRight:NO];
        }

        // If left sibling has more than min elements, rotate right
        else if (node.previous && node.previous.parent == node.parent
            && node.previous.data.count > self.nodeMinimum) {
            [self rotateNode:node toRight:YES]; 
        }

        // Otherwise, need to merge node with one of its siblings
        else {
            [self mergeSiblingWithNode:node];
        }

    }
    
    // For debugging, check if has valid pointer structure
//    if (![node hasValidPointerStructure]) {
//        NSLog(@"Invalid pointer state on node: %@", node);
//    } 
       
//    NSLog(@"Tree After operation on node: %@ \n%@", node, [self printTree]);     
}

- (void)rotateNode:(NUTreeNode *)node toRight:(BOOL)direction
{
//    NSLog(@"Rotate node %@ %@", node, (direction ? @"Right" : @"Left"));

    // Can't rotate if no node, no siblings in direction to rotate, 
    //  or no data in sibling, or siblings not from same parent
    if (!node || !node.parent || !node.parent.data.count
        || (!direction && (!node.next 
            || node.next.parent != node.parent 
            || !node.next.data.count)) 
        || (direction && (!node.previous
            || node.previous.parent != node.parent 
            || !node.previous.data.count))) {
        NSLog(@"Warning! Rotating on node without sibling in right direction: %@", node); 
        return;
    }
    
    // Get index of node in children array of parent
    NSUInteger indexOfChild = [node.parent indexOfChildNode:node];
    if (indexOfChild == NSNotFound) {
        NSLog(@"Warning! Could not find index of child in parent: %@", node);
        return;
    }
    
    // Insert parent data that is next to the node
    NSUInteger indexOfParentData = indexOfChild - direction;
    NSUInteger indexOfInsert = (direction ? 0 : node.data.count);
    [node.data insertObject:node.parent.data[indexOfParentData] 
                    atIndex:indexOfInsert];
    
    // Replace parent data with data from sibling
    NUTreeNode *sibling = (direction ? node.previous : node.next);
    NSUInteger indexOfRemove = (direction ? sibling.data.count - 1 : 0); 
    [node.parent.data replaceObjectAtIndex:indexOfParentData 
                                withObject:sibling.data[indexOfRemove]];
    [sibling.data removeObjectAtIndex:indexOfRemove];
    
    // Also move corresponding child of sibling to node if needed
    if (sibling.children.count) 
    {
        indexOfRemove += (direction ? 1 : 0);   // +1 if rotating right
        NUTreeNode *child = sibling.children[indexOfRemove];
        
        // Move to node
        indexOfInsert += (direction ? 0 : 1);   // +1 if rotating left
        [node.children insertObject:child atIndex:indexOfInsert];
        child.parent = node;    // Change parents, but siblings are the same 
        
        // Remove from sibling
        [sibling.children removeObjectAtIndex:indexOfRemove];
    }
}

- (void)mergeSiblingWithNode:(NUTreeNode *)node
{
//    NSLog(@"Merge on node: %@", node);
    
    // Sanity checks: need siblings or node to exist
    if (!node || (!node.previous && !node.next)) {
        NSLog(@"Warning! Merge called on node with no siblings!");
        NSLog(@"Tree: \n%@", [self printTree]);
        return;
    }
    
    // Setup for merge
    NUTreeNode *leftNode, *rightNode, *parent;
    
    // Merge with right node if possible
    if (node.next && node.next.parent == node.parent)
    {
        leftNode = node;
        rightNode = node.next;
    }
    // If we can't merge with right node, merge left
    else if (node.previous && node.previous.parent == node.parent)
    {
        leftNode = node.previous;
        rightNode = node;
    }
    // This shouldn't happen
    else {
        NSLog(@"Warning! Reached end of merge with no siblings!");
        NSLog(@"Tree: \n%@", [self printTree]); 
        return;
    }
    
    // Find index of separator object in parent
    parent = leftNode.parent;
    NSUInteger index = [parent indexOfChildNode:leftNode];
    
    // Transfer data & children over from parent / right node
    [leftNode.data addObject:parent.data[index]];
    for (NSUInteger i = 0; i < rightNode.data.count; ++i) {
        [leftNode.data addObject:rightNode.data[i]];
    } 
    for (NSUInteger i = 0; i < rightNode.children.count; ++i) {
        [leftNode.children addObject:rightNode.children[i]];
        [rightNode.children[i] setParent:leftNode]; 
    }
    
    // Clean up parent / right node
    [parent.data removeObjectAtIndex:index];
    [parent.children removeObjectAtIndex:index + 1];
    leftNode.next = rightNode.next;
    if (rightNode.next) {
        rightNode.next.previous = leftNode;
    }
    rightNode.next = rightNode.previous = rightNode.parent = nil;
    [rightNode.children removeAllObjects];
    [rightNode.data removeAllObjects]; 
    
    // Rebalance parent if needed
    if (parent.data.count < self.nodeMinimum)
    {
        // If parent is empty root, make leftNode new root
        if (parent == self.root && parent.data.count == 0)
        {
            parent.previous = parent.next = parent.parent = nil;
            [parent.children removeAllObjects];
            leftNode.parent = nil; 
            self.root = leftNode;
        }
        else {
            [self rebalanceNode:parent];
        }
    }
}


#pragma mark - NSFastEnumeration

/** @brief Implementing fast enumeration in a simple way, using our cache */
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id *)stackbuf count:(NSUInteger)len
{
    // First-time setup
    if (state->state == 0)
    {
        // Track when mutations happen
        state->mutationsPtr = (unsigned long *)&_cacheOutdated;
        
        // Build cache if does not exist
        if (!self.cache) {
            [self rebuildCache];
        }
        
        // Set flag to prevent cache changing
        self.fastEnumerating = YES;
    }
   
    // Loop as long as more data is available
    if (state->state < self.count)
    {
        // Iterate and fill stackbuf
        NSUInteger count = 0;  
        state->itemsPtr = stackbuf;  
        while (state->state < self.count && (count < len))
        {
            stackbuf[count++] = [self objectAtIndex:state->state];
            state->state++;
        }
        
        // Set items returned to stackbuf, return count of items
        return count;
    }
    
    // Done iterating, clear enumerating flag and return 0
    self.fastEnumerating = NO;
    return 0;
}


#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    id copy = [[[self class] alloc] init];
    
    if (copy) {
        [copy setRoot:[self.root copyWithZone:zone]];
        [copy setNodeCapacity:self.nodeCapacity]; 
        [copy setNodeMinimum:self.nodeMinimum]; 
    }
    
    return copy;
}


@end
