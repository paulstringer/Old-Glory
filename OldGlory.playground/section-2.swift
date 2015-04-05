 // Old Glory - a common nickname for the flag of the United States, bestowed by William Driver, an early nineteenth-century American sea captain. However, it also refers specifically to the flag owned by Driver, which has become one of the U.S.'s most treasured historical artifacts. - http://en.wikipedia.org/wiki/Old_Glory

import UIKit


// MARK: - Array Extension

// Extension to Array providing a CSS like nth-child selector

extension Array {
	
	/// CSS like nth-child selector
	///
	/// :param: start 1 based index used to determine the start position
	/// :returns: Every nth item beginning with the item at start.
	
	func nthchild(var n:Int, var start:Int) -> Array {
		return self[n,start]
	}
	
	subscript(var n:Int, var start:Int) -> Array {
		
		var results: [T] = []
		
		if self.isEmpty {
			return results;
		}
		
		var count = 0
		var position = start
		
		while position <= self.count {
			if position > 0 {
				var index = position-1
				results.append(self[index])
			}
			count++
			position = (n*count) + start
		}
		
		return results
		
	}
}

// Extension to UIView providing CSS like float:left property

extension UIView {
	
	
	/// Floats receivers subviews to the left similar to how CSS float:left works
	/// Calling this will cause all the receivers subviews frames to be updated so that each is positioned to the right of it's preceding sibling. When available width of the receivers frame prevents this subviews move to new lines.
	
	func floatLeftSubviews() {
		
		var previousView: UIView?
		var line: CGFloat = 0.0
		
		for view in self.subviews as [UIView]
		{
			/// Normalize origin
			view.frame.origin = CGPointMake(0, 0)
			
			if let previousViewFrame = previousView?.frame  {
				var floatedViewRect = CGRectOffset(view.frame, CGRectGetMaxX(previousViewFrame), previousViewFrame.origin.y)
				var needsNewLine = CGRectGetMaxX(floatedViewRect) > CGRectGetMaxX(self.frame)
				if needsNewLine {
					line++
					floatedViewRect.origin.y = CGFloat(line * floatedViewRect.size.height)
					floatedViewRect.origin.x = CGFloat(0)
				}
				view.frame = floatedViewRect
			}
			
			previousView = view
		}
		
	}
	
	/// Adds an Array of Views to this View's subviews
	///
	/// :param: view The views to be added
	func addSubviews(views:[UIView]) {
		for view in views {
			self.addSubview(view)
		}
	}
}

// MARK: - Old Glory


/// A struct that defines the number of rows and columns found in the Union of The United States flag.
///
/// - Rows: The number of rows of stars
/// - Columns: The number of columns of stars on even rows, alternate rows have 5 columns

struct OldGloryUnionMatrix {
	static let Rows = 9
	static let Columns = 6
}

/// A struct that defines the attributes of Old Glory
///
/// - NumberOfBritishColonies: The number of British colonies that declared independence from the Kingdom of Great Britain and became the first states in the Union
/// - NumberOfStatesOfTheUnion: The 50 states of the United States of America

struct OldGloryAttributes {
	static let NumberOfBritishColonies = 13
	static let NumberOfStatesOfTheUnion = 50
}


/**
Struct providing metrics for each of the components of The United States Flag given a width. Metrics are based on the usflag.org specification http://www.usflag.org/flagspecs.html
*/

struct OldGloryMetrics {
	
	/// The Size of Canton
	var cantonSize = CGSizeZero

	/// The size of Stripe representing each of the 13 British Colonies
	var stripeSize = CGSizeZero
	
	/// The Size of Flag
	var flagSize = CGSizeZero
	
	/// The Size of Union Star
	var starSize = CGSizeZero
	
	/// The Offset of Star
	var starOffset = CGPointZero
	

	/// Initializes an Old Glory measurement for the given width
	///
	/// :param: width The width used to calculate the metrics
	
	init(width: CGFloat) {
		
		// Calculate Old Glory metrics based on Old Glory proportions found at usflag.org
		
		let fly = width
		let hoist = (fly / 1.9) * 1.0
		let unionFly = hoist * 0.76
		let unionHoist = hoist * 0.5385
		let starDiameter = hoist * 0.0616
		let stripeHoist = hoist * 0.0769
		let starOffsetY = hoist * 0.054
		let starOffsetX = hoist * 0.063
		
		starSize = CGSizeMake(starDiameter, starDiameter)
		starOffset = CGPointMake(starOffsetX, starOffsetY)
		cantonSize = CGSizeMake(unionFly, unionHoist)
		stripeSize = CGSizeMake(fly, stripeHoist)
		flagSize = CGSizeMake(fly, hoist)

	}
	
}

/**
Old Glory is the flag of the United States of America represented by 13 alternating red and white
stripes of equal height, one for each of the British Colonies. A blue Canton known as the Union contains 50 stars, one
representing each of the states of the Union.
*/

class OldGlory : UIView {

	var star: UIImage
	var measurements: OldGloryMetrics
	
	/// The designated initializer creating an Old Glory flag that's size is based on the received width
	///
	/// :param: width A width used to calculate the size of the view
	
	init(width: CGFloat) {
		
		/// Create Star Image
		star = UIImage(named: "star")!
		
		/// Create Measurements with Width
		measurements = OldGloryMetrics(width: width)
		
		/// Modify Frame to be correct for this Star size
		let newFrame = CGRectMake(0, 0, measurements.flagSize.width, measurements.flagSize.height)
		
		super.init(frame: newFrame)
		
	}
	
	override convenience init(frame: CGRect) {
		self.init(width:frame.size.width)
	}

	required init(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented use init:(width:)")
	}
	
	override func layoutSubviews() {
		layoutStarsAndStripes()
	}
	
	private func layoutStarsAndStripes() {
		self.addSubviews(stripeViews())
		self.addSubview(unionView())
	}
	
	private func unionView() -> UIView {
		
		// Create Union View
		let unionSize = measurements.cantonSize
		let union = UIView(frame: CGRectMake(0, 0, unionSize.width, unionSize.height))
		union.backgroundColor = UIColor.blueColor()
		
		// Get points for positioning Stars
		let starPoints = unionStarCenterPointsForUnionView(union)
		
		// Convert Points to Star Image Views and Add Views to Union
		let starViews = starViewsPositionedAtCenterPoints(starPoints)
		union.addSubviews(starViews)
		
		return union
		
	}
	
	private func unionStarCenterPointsForUnionView(union: UIView) -> [CGPoint] {
		
		// Subdivide the Union to form an easy grid reference for calculating points
		var blockSize = CGSizeMake(measurements.starOffset.x * 2, measurements.starOffset.y)
		let unionBlocks = viewsOfSize(blockSize, bySubdividingForFrameSize:union.frame.size)
		
		// Indent left the subdivided blocks at the beginning of each alternate row
		for view in unionBlocks.nthchild(12, start: 1) {
			view.frame.size.width = measurements.starOffset.x
		}
		
		// Float left the blocks within the Union to assign correct frames to the block views
		union.addSubviews(unionBlocks)
		union.floatLeftSubviews()
		
		// Get list of star points using each blocks bottom right point
		let starPoints = convertUnionBlockViewsToStarPoints(unionBlocks, forFrame: union.frame)
		
		return starPoints
	}
	
	private func convertUnionBlockViewsToStarPoints(blocks: [UIView], forFrame frame:CGRect) -> [CGPoint] {
		
		// Get a list of star points using each blocks bottom right point
		var starPoints: [CGPoint] = []
		var blockIndex = 0
		do {
			let block = blocks[blockIndex]
			let bottomRight = CGPointMake(CGRectGetMaxX(block.frame), CGRectGetMaxY(block.frame))
			let starMaxX = bottomRight.x + measurements.starSize.width
			// Add Point only if the Star is contained horizontally within the frame
			if starMaxX < CGRectGetMaxX(frame) {
				starPoints.append(bottomRight)
			}
			blockIndex++
		} while starPoints.count < OldGloryAttributes.NumberOfStatesOfTheUnion
		
		return starPoints
	}
	
	private func starViewsPositionedAtCenterPoints(points: [CGPoint]) -> [UIImageView] {
		var starViews: [UIImageView] = []
		let image = UIImage(named: "star")
		for point in points {
			let imageView = UIImageView(image: image)
			imageView.frame = CGRectMake(0, 0, measurements.starSize.width, measurements.starSize.height)
			imageView.center = point
			starViews.append(imageView)
		}
		return starViews
	}
	
	private func viewsOfSize(size: CGSize, bySubdividingForFrameSize frameSize: CGSize) -> [UIView] {
		
		let blockFrame = CGRectMake(0, 0, size.width, size.height)
		var blockViews: [UIView] = []
		
		let boxSize  = Int(size.width * size.height)
		let fillSize = Int(frameSize.height * frameSize.width)
		let numberOfBlocks = fillSize / boxSize
		
		for _ in 1...numberOfBlocks {
			let blockView = UIView(frame: blockFrame)
			blockViews.append(blockView)
		}
		
		return blockViews
	}
	
	private func stripeViews() -> [UIView] {
		
		var stripeViews: [UIView] = []
		var stripeSize = measurements.stripeSize
		
		// Create a stripe view for each of the british colonies
		for index in 1...OldGloryAttributes.NumberOfBritishColonies {
			var x = CGFloat(0.0)
			var y = CGFloat(stripeSize.height * CGFloat(index-1))
			var stripeView = UIView(frame: CGRectMake(x, y, stripeSize.width, stripeSize.height))
			stripeViews.append(stripeView)
		}
		
		// Color every 2nd stripe red beginning from the 1st
		for stripe in stripeViews.nthchild(2, start: 1) {
			stripe.backgroundColor = UIColor.redColor()
		}
		
		// Color every 2nd stripe white beginning from the 2nd
		for stripe in stripeViews.nthchild(2, start: 2) {
			stripe.backgroundColor = UIColor.whiteColor()
		}
		
		return stripeViews
	}
	
	
}


let flag = OldGlory(width: 250.0)
