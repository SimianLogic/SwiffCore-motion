class DemoMovieController < UIViewController
  
  PROMOTE_ALL_PLACED_OBJECTS_TO_LAYERS = 0
  
  MOVIE_CACHE = "MovieCache"
  
  def initWithURL(ns_url)
    @movieURL = ns_url    
    self
  end
  
  def self.setCachedData(url, data)
    defaults = NSUserDefaults.standardUserDefaults
    base_dictionary = defaults.objectForKey(MOVIE_CACHE)
    dictionary = base_dictionary.clone if base_dictionary
    if(!dictionary)
      dictionary = NSMutableDictionary.alloc.init
    end
    
    dictionary.setObject(data, forKey:url.absoluteString)
    defaults.setObject(dictionary, forKey:MOVIE_CACHE)
    defaults.synchronize
  end
  
  #may need to unwind this a bit to nil check
  def self.getCachedData(url)
    if cache = NSUserDefaults.standardUserDefaults.objectForKey(MOVIE_CACHE)
      return cache.objectForKey(url.absoluteString)
    end
    nil
  end
  
  def viewDidLoad
    super
    
    selfView = self.view
    bounds = selfView.bounds
    bottomHeight = 44.0
    
    sliderFrame = CGRectInset(bounds, 128.0, 0.0)
    sliderFrame.origin.y = sliderFrame.size.height - bottomHeight
    sliderFrame.size.height = bottomHeight
    
    playButtonFrame = bounds
    playButtonFrame.origin.x = 0.0
    playButtonFrame.origin.y = playButtonFrame.size.height - bottomHeight
    playButtonFrame.size.height = bottomHeight
    playButtonFrame.size.width = 128.0
    playButtonFrame = CGRectInset(playButtonFrame, 32.0, 0.0)
    
    @timelineSlider = UISlider.alloc.initWithFrame(sliderFrame)
    @timelineSlider.addTarget(self, action:"handleSliderDidChange:", forControlEvents:UIControlEventValueChanged)
    @timelineSlider.setContinuous(true)
    @timelineSlider.setAutoresizingMask((UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin))
    selfView.addSubview(@timelineSlider)

    @playButton = UIButton.alloc.initWithFrame(playButtonFrame)
    @playButton.addTarget(self, action:"handlePlayButtonTapped:", forControlEvents:UIControlEventTouchUpInside)
    @playButton.setAutoresizingMask(UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin)
    @playButton.setTitle("Play", forState:UIControlStateNormal)
    selfView.addSubview(@playButton)
    
    movie_data = DemoMovieController::getCachedData(@movieURL)
    if(movie_data)
      @movieData = movie_data
      self.loadMovie
    else
      self.loadMovieData
    end

  end

  def viewDidUnload
    super
    cleanupViews
  end

  #UIInterfaceOrientationIsLandscape is a macro!
  def shouldAutorotateToInterfaceOrientation(toInterfaceOrientation)
     toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight
  end

  def gotoFrameNumber(frameNumber)
    @frameNumber = frameNumber
    @movieView.playhead.gotoFrameWIthIndex(@frameNumber, play:false)
  end

  def loadMovie

    @movie = SwiffMovie.alloc.initWithData(@movieData)

#   @timelineSlider.setMaximumValue(@movie.frames.count -1)
    @timelineSlider.maximumValue = @movie.frames.count - 1

    movie_frame = self.view.bounds
    movie_frame.size.height -= 44
    
    #if PROMOTE_ALL_PLACED_OBJECTS_TO_LAYERS
      @movie.frames.each do |frame|
        frame.placedObjects.each do |object|
          object.setWantsLayer(true)
        end
      end
    #end
    
    @movieView = SwiffView.alloc.initWithFrame(movie_frame, movie:@movie)
    @movieView.setDelegate(self)
    @movieView.setBackgroundColor(UIColor.whiteColor)
    @movieView.setAutoresizingMask(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)
    self.view.addSubview(@movieView)

  end
  
  def loadMovieData
    if @movieURL.scheme == "bundle"
      filename = @movieURL.resourceSpecifier
      resource_path = NSBundle.mainBundle.pathForResource(filename.stringByDeletingPathExtension, ofType:filename.pathExtension)
      
      if resource_path
        @movieData = NSData.alloc.initWithContentsOfFile(resource_path)
        self.loadMovie
      end
    else
      Dispatch::Queue.concurrent.async do
        error = nil
        response = nil
        error_ptr = Pointer.new(:object)
        response_ptr = Pointer.new(:object)
        
        request = NSURLRequest.requestWithURL(@movieURL)
        movie_data = NSURLConnection.sendSynchronousRequest(request, returningResponse:response_ptr, error:error_ptr)
        
        Dispatch::Queue.concurrent.async do
          @movieData = movie_data
          DemoMovieController::setCachedData(@movieURL, @movieData)
          
          self.loadMovie if @movieData.length
        end
        
      end
    end
  end
  
  def cleanupViews
    @timelineSlider.removeTarget(self, action:"handleSliderDidChange:", forControlEvents:UIControlEventValueChanged)
    @timelineSlider = nil
    
    @playButton.removeTarget(self, action:"handlePlayButtonTapped:", forControlEvents:UIControlEventTouchUpInside)
    @playButton = nil
    
    @movieView.setDelegate(nil)
    @movieView = nil
  end

  def handleSliderDidChange(sender)
    value = @timelineSlider.value
    @movieView.playhead.gotoFrameWithIndex(value.round, play:false)
  end
  
  def handlePlayButtonTapped(sender)
    shouldPlay = !@movieView.playhead.isPlaying
    if(shouldPlay)
      @movieView.playhead.play
    else
      @movieView.playhead.stop
    end
    
    @playButton.setTitle((shouldPlay ? "Pause" : "Play"), forState:UIControlStateNormal)
  end

  #pragma mark SwiffMovieView Delegate
  def swiffView(swiffView, didUpdateCurrentFrame:frame)
    i = @movieView.playhead.frame.indexInMovie
    @timelineSlider.setValue(i.to_f)
  end

  
end