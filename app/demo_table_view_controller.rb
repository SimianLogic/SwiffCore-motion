CURRENT_MOVIE_KEY = "CurrentMovie"

class DemoTableViewController < UITableViewController
  
  def initWithStyle(tableStyle)
    super(tableStyle)
    
    plistPath = NSBundle.mainBundle.pathForResource("DemoMovies", ofType:"plist")
    plistData = NSData.dataWithContentsOfFile(plistPath)
    
    error_ptr = Pointer.new(:object)
    
    @moviesPlist = NSPropertyListSerialization.propertyListWithData(plistData, options:NSPropertyListImmutable, format:nil, error:error_ptr)
    setTitle("Movies")
    
    self
  end
  
  def viewDidAppear(animated)
    NSUserDefaults.standardUserDefaults.removeObjectForKey(CURRENT_MOVIE_KEY)
  end
  
  #UIInterfaceOrientationIsLandscape is a macro!
  def shouldAutorotateToInterfaceOrientation(toInterfaceOrientation)
     toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight
  end
  
  def movieDictionaries
    @moviesPlist.objectForKey("movies")
  end
  
  def pushMovieWithURLString(inURLString, animated:animated)
    p "PUSHING #{inURLString}"
    movie_dictionaries = self.movieDictionaries

    movie_dictionaries.each do |dictionary|

      urlString = dictionary.objectForKey("url")
      if(urlString.to_s == inURLString.to_s)

        url = NSURL.URLWithString(urlString)
        title = dictionary.objectForKey("name")
        classname = dictionary.objectForKey("classname")

        vc = DemoMovieController.alloc.initWithURL(url, andSymbol:classname)
        vc.setTitle(title)
        
        self.navigationController.pushViewController(vc, animated:animated)
        NSUserDefaults.standardUserDefaults.setObject(urlString, forKey:CURRENT_MOVIE_KEY)
        NSUserDefaults.standardUserDefaults.synchronize
        
        break
      end
    end
  end

  def tableView(tableView, numberOfRowsInSection:section)
    self.movieDictionaries.count
  end
  
  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    dictionary = self.movieDictionaries.objectAtIndex(indexPath.row)
    
    urlString = dictionary.objectForKey("url")
    NSUserDefaults.standardUserDefaults.setObject(urlString, forKey:CURRENT_MOVIE_KEY)
    
    self.pushMovieWithURLString(urlString, animated:true)
  end
  
  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    identifier = "cell"
    cell = tableView.dequeueReusableCellWithIdentifier(identifier)
    
    if cell.nil?
      cell = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleSubtitle, reuseIdentifier:identifier)
    end
    
    dictionary = self.movieDictionaries.objectAtIndex(indexPath.row)
    
    cell.textLabel.setText(dictionary.objectForKey("name"))
    cell.detailTextLabel.setText(dictionary.objectForKey("author"))
    
    return cell
  end
  
end

