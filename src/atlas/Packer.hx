package atlas;

private typedef Position = {
  var column: Int;
  var row: Int;
}

/**
 * Pack rectangles in bounds.
 * The optimal option is based on this post.
 * https://www.codeproject.com/Articles/210979/Fast-optimizing-rectangle-packing-algorithm-for-bu
 * 
 * Sort the rectangles by height, highest first.
 * 
 * Make the bounds the width of the total width of all rectangles and the height the height of the highest rectangle.
 * 
 * There is a dynamic grid with booleans of where the placed rectangles are.
 * 
 * There is a separate array with all column widths and one with a row heights in the grid.
 * 
 * Each rectangle is inserted at the left most possible position.
 * 
 * The grid column and row that overlap the ends of the inserted rectangle get divided by the space left empty.
 * 
 * This is repeated until all rectangles are placed or one doesn't fit.
 * 
 * If one doesn't fit, increase the height of the bounds by the height of the rectangle that didn't fit and restart
 * the process.
 * 
 * If all fit make the bounds width smaller until it fits the rectangle exactly. If the area of the bounds this pass
 * is smaller that the current smallest bounds save it and the rectangle positions.
 * 
 * Subtract 1 pixels from the bounds width. if it is smaller than the width of the widest rectangle the process is
 * done. If not restart the process with the new bounds.
 */
class Packer {
  /**
   * All rectangles that need to be packed.
   */
  var rectangles: Array<Rectangle>;

  /**
   * The current bounds of the packer image.
   */
  var bounds: Rectangle;

  /**
   * A list of rectangles that have been placed on this pass.
   */
  var placedRectangles: Array<Rectangle>;

  /**
   * A list of row sizes for the dynamic grid in pixels.
   */
  var gridRows: Array<Int>;

  /**
   * A list of column sizes for the dynamic grid in pixels.
   */
  var gridColumns: Array<Int>;

  /**
   * Dynamic grid that has the filled and empty positions in the grid.
   */
  var grid: Array<Array<Bool>>;

  /**
   * The number of placed rectangles in the grid.
   */
  var placed: Int;

  /**
   * The current smallest bounds of the packed rectangles.
   */
  public var smallestBounds: Rectangle;

  /**
   * The layout of rectangles for the smallest bounds.
   */
  public var smallestLayout: Array<Rectangle>;

  /**
   * The width of the widest rectangle.
   */
  var biggestWidth: Int;

  /**
   * The maximum width the bounds can be.
   */
  var maxWidth: Int;

  /**
   * The maximum height the bounds can be.
   */
  var maxHeight: Int;

  /**
   * Simple or optimal packing method depending on the atlas config.
   */
  var packMethod: PackMethod;

  /**
   * Constructor.
   * @param rectangles The rectangles to pack in the atlas.
   * @param packMethod The method to use for the packing.
   * @param maxWidth The maximum width of the atlas in pixels.
   * @param maxHeight The maximum height of the atlas in pixels.
   */
  public function new(rectangles: Array<Rectangle>, packMethod: PackMethod, maxWidth: Int, maxHeight: Int) {
    this.rectangles = rectangles;
    this.packMethod = packMethod;
    this.maxWidth = maxWidth;
    this.maxHeight = maxHeight;

    placedRectangles = [];
    gridRows = [];
    gridColumns = [];
    grid = [];
    placed = 0;
    smallestLayout = [];
    biggestWidth = 0;

    sortRects();
    setStartBounds();
    resetPlacements();
  }

  /**
   * Pack the rectangles.
   */
  public function pack(): Bool {
    if (packMethod == BASIC) {
      if (!packRectangles()) {
        #if !unit_testing
        Sys.println('Error: Unable to fit the images inside the bounds.');
        #end
        return false;
      }
      return true;
    } else {
      var success = true;
      var done = false;
      while (!done) {
        if (packRectangles()) {
          bounds.width -= 1;
          if (bounds.width < biggestWidth) {
            done = true;
          } else {
            resetPlacements();
          }
        } else {
          if (smallestBounds == null) {
            #if !unit_testing
            Sys.println('Error: Unable to fit the images inside the bounds.');
            #end
            success = false;
          }
          done = true;
        }
      }

      return success;
    }
  }

  /**
   * Set the bounds for the first pass.
   */
  function setStartBounds() {
    var boundsWidth = 0;
    var boundsHeight = 0;
    for (rect in rectangles) {
      if (boundsHeight == 0 || rect.height > boundsHeight) {
        boundsHeight = rect.height;
      }
      boundsWidth += rect.width;
      if (biggestWidth == 0 || rect.width > biggestWidth) {
        biggestWidth = rect.width;
      }
    }

    if (boundsWidth > maxWidth) {
      boundsWidth = maxWidth;
    }

    bounds = new Rectangle({
      x: 0,
      y: 0,
      width: boundsWidth,
      height: boundsHeight
    });
  }

  /**
   * Run a packing pass.
   * @return True if all rectangles fit.
   */
  function packRectangles(): Bool {
    while (placed < rectangles.length) {
      var rectangle = rectangles[placed];
      if (placeRectangle(rectangle)) {
        placedRectangles.push(rectangle);
        placed++;
      } else {
        bounds.height += rectangle.height;
        if (bounds.height > maxHeight) {
          return false;
        }
        resetPlacements();
      }
    }

    // Find the width of of the packed rectangles to decrease the bounds width.
    var totalWidth = 0;
    for (x in 0...gridColumns.length) {
      for (y in 0...gridRows.length) {
        if (grid[y][x]) {
          totalWidth += gridColumns[x];
          break;
        }
      }
    }

    // Update the smallest bounds.
    bounds.width = totalWidth;
    if (smallestBounds == null || bounds.area() < smallestBounds.area()) {
      smallestBounds = bounds.clone();
      smallestLayout = [];
      for (rect in placedRectangles) {
        smallestLayout.push(rect.clone());
      }
    }

    return true;
  }

  /**
   * Reset for a new pass.
   */
  function resetPlacements() {
    placedRectangles = [];
    placed = 0;
    grid = [[false]];
    gridColumns = [bounds.width];
    gridRows = [bounds.height];
  }

  /**
   * Add a rectangle into the grid.
   * @param rect The rectangle to add.
   * @return True if the the rectangle got placed.
   */
  function placeRectangle(rect: Rectangle): Bool {
    if (packMethod == BASIC) {
      // Find top most empty spot.
      for (row in 0...gridRows.length) {
        for (column in 0...gridColumns.length) {
          if (!grid[row][column]) {
            if (findPlace({ column: column, row: row }, rect)) {
              return true;
            }
          }
        }
      }
    } else {
      // Find left most empty spot.
      for (column in 0...gridColumns.length) {
        for (row in 0...gridRows.length) {
          if (!grid[row][column]) {
            if (findPlace({ column: column, row: row }, rect)) {
              return true;
            }
          }
        }
      }
    }

    return false;
  }

  /**
   * Find an empty spot for the rectangle as much left as possible.
   * @param startColumn The column to start checking.
   * @param startRow The row to start checking.
   * @param rectangle The rectangle to place.
   * @return True if the rectangle got placed.
   */
  function findPlace(start: Position, rectangle: Rectangle): Bool {
    final end: Position = { column: start.column, row: start.row };
    final total: Size = { width: gridColumns[start.column], height: gridRows[start.row] };

    // Check the rows down adding to the total height until the rectangle fits.
    while (end.row < gridRows.length) {
      // Cell not empty. The rectangle won't fit here.
      if (grid[end.row][end.column]) {
        return false;
      }

      // The total height fits the rectangle.
      if (total.height >= rectangle.height) {
        break;
      }

      end.row++;
      if (end.row < gridRows.length) {
        total.height += gridRows[end.row];
      }
    }

    // End row out of range of the rows. Rectangle doesn't fit here.
    if (end.row >= gridRows.length) {
      return false;
    }

    // Check the columns right of the start adding to the total width until the rectangle fits.
    while (end.column < gridColumns.length) {
      for (y in start.row...end.row + 1) {
        if (grid[y][end.column]) {
          return false;
        }
      }

      if (total.width >= rectangle.width) {
        break;
      }

      end.column++;
      if (end.column < gridColumns.length) {
        total.width += gridColumns[end.column];
      }
    }

    if (end.column >= gridColumns.length) {
      return false;
    }

    insertRect(total, start, end, rectangle);

    return true;
  }

  /**
   * Insert a rectangle into the grid.
   * @param props The insert properties
   */
  function insertRect(total: Size, start: Position, end: Position, rectangle: Rectangle) {
    final widthLeft = total.width - rectangle.width;
    final heightLeft = total.height - rectangle.height;

    // Divide the grid row that contains the last part of the new rectangle.
    if (heightLeft > 0) {
      gridRows[end.row] = gridRows[end.row] - heightLeft;
      gridRows.insert(end.row + 1, heightLeft);
      insertRow(end.row + 1);
    }

    // Divide the grid column that contains the last part of the new rect.
    if (widthLeft > 0) {
      gridColumns[end.column] = gridColumns[end.column] - widthLeft;
      gridColumns.insert(end.column + 1, widthLeft);
      insertColumn(end.column + 1);
    }

    for (i in start.row...end.row + 1) {
      for (j in start.column...end.column + 1) {
        grid[i][j] = true;
      }
    }

    var xPos = 0;
    for (col in 0...start.column) {
      xPos += gridColumns[col];
    }

    var yPos = 0;
    for (row in 0...start.row) {
      yPos += gridRows[row];
    }

    rectangle.x = xPos;
    rectangle.y = yPos;
  }

  /**
   * Insert a row into the packer grid.
   * @param index The position where you want to insert the row.
   */
  function insertRow(index: Int) {
    final copy = grid[index - 1].copy();
    grid.insert(index, copy);
  }

  /**
   * Insert a column into the packer grid.
   * @param index The position where you want to insert the column.
   */
  function insertColumn(index: Int) {
    for (row in grid) {
      row.insert(index, row[index - 1]);
    }
  }

  function sortRects() {
    if (packMethod == BASIC) {
      sortByName();
    } else {
      sortByHeight();
    }
  }

  function sortByHeight() {
    rectangles.sort((a: Rectangle, b: Rectangle) -> {
      if (a.height > b.height) {
        return -1;
      } else if (a.height < b.height) {
        return 1;
      } else {
        return 0;
      }
    });
  }

  function sortByName() {
    rectangles.sort((a: Rectangle, b: Rectangle) -> {
      if (a.name > b.name) {
        return 1;
      } else if (a.name < b.name) {
        return -1;
      } else {
        return 0;
      }
    });
  }
}
