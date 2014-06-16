# PMBrowsingCollectionView

PMBrowsingCollectionView is a subclass of UICollectionView that implements a new interaction for easily browsing through a collection of cells by introducing the concept of expanded vs. collapsed sections.

![Demo](http://pm-dev.github.io/PMBrowsingCollectionView.gif)

## Requirements & Notes

- PMBrowsingCollectionView was built for iOS and requires a minimum iOS target of iOS 7.
- Thorough commenting of header files is currently in progress. (6/12/14).
- PMBrowsingCollectionView will not support resizing until dynamic cell resizing is added in iOS8

## How To Get Started

- Check out the documentation (coming soon).

### Installation with CocoaPods

PMBrowsingCollectionView is available through [CocoaPods](http://cocoapods.org). [CocoaPods](http://cocoapods.org) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries like PMBrowsingCollectionView in your projects. See the ["Getting Started" guide for more information](http://guides.cocoapods.org/using/getting-started.html).

#### Podfile

To install, simply add the following line to your Podfile.

```ruby
platform :ios, '7.0'
pod "PMBrowsingCollectionView"
```

## Usage

To see PMBrowsingCollectionView in action, run the example project at /Example/PMBrowsingCollectionView-iOSExample.xcworkspace.
After installing the PMBrowsingCollectionView pod, integrating into your project is as easy as creating a typical UICollectionView:

```objective-c

UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
layout.scrollDirection = UICollectionViewScrollDirectionVertical;
layout.minimumInteritemSpacing = 2.0f;
layout.minimumLineSpacing = 2.0f;
	
PMBrowsingCollectionView *collectionView = [PMBrowsingCollectionView collectionViewWithFrame:self.view.bounds
                                                                            collectionViewLayout:layout];
collectionView.delegate = self;
collectionView.dataSource = self;
[collectionView registerClass:[UICollectionViewCell class]
            forCellWithReuseIdentifier:@"cellReuseIdentifier"];
[collectionView registerClass:[UICollectionReusableView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:@"headerReuseIdentifier"];
[self.view addSubview:collectionView];

```

```objective-c
- (UICollectionViewCell *)collectionView:(PMBrowsingCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellReuseIdentifier" forIndexPath:indexPath];
	NSUInteger normalizedIndex = [collectionView normalizeItemIndex:indexPath.item forSection:indexPath.section];
	/*
	* Configure cell based on indexPath.section and normalizedIndex
	*/
	return cell;
}
```

PMBrowsingCollectionViewDelegate adds three optional methods to the UICollectionViewDelegateFlowLayout:

```objective-c

- (CGFloat) collectionView:(PMBrowsingCollectionView *)collectionView shadowRadiusForSection:(NSInteger)section
{
    return 20.0f;
}

- (UIColor *) collectionView:(PMBrowsingCollectionView *)collectionView shadowColorForSection:(NSInteger)section
{
    return [UIColor blackColor];
}

// Only called when section is in a collapsed state.
- (void) collectionView:(PMBrowsingCollectionView *)collectionView willCenterItemAtIndexPath:(NSIndexPath *)indexPath
{
	NSUInteger normalizedIndex = [collectionView normalizeIndex:indexPath.item];
	DLog(@"Will center cell at section index %d, item index %d", indexPath.section, normalizedIndex);
}

```
#### Discussion

 - To achieve infinite scrolling, PMCircularCollectionView employes a technique described in [this blog post](http://iphone2020.wordpress.com/2012/10/01/uitableview-tricks-part-2-infinite-scrolling) which multiplies the content size and consequently the number of index paths. Thus, it is possible for dataSource and delegate methods to pass an index path with item == 15, when less than 16 items were returned to the -collectionView:numberOfItemsInSection: delegate method. As seen in the examples above, call -normalizeItemIndex:forSection to change the item index to the correct value.

## Communication

- If you **need help**, use [Stack Overflow](http://stackoverflow.com/questions/tagged/PMTabBarController). (Tag 'PMTabBarController')
- If you'd like to **ask a general question**, use [Stack Overflow](http://stackoverflow.com/questions/tagged/PMTabBarController).
- If you **found a bug**, open an issue.
- If you **have a feature request**, open an issue.
- If you **want to contribute**, submit a pull request.


## Author

- [Peter Meyers](mailto:petermeyers1@gmail.com)

## License

PMBrowsingCollectionView is available under the MIT license. See the LICENSE file for more info.
