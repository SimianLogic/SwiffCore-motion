# class AppDelegate
#   def application(application, didFinishLaunchingWithOptions:launchOptions)
#     true
#   end
# end


class AppDelegate
  #@window
  #@viewController
  
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    
    vc = DemoTableViewController.alloc.initWithStyle(UITableViewStylePlain)
    nc = UINavigationController.alloc.initWithRootViewController(vc)
    
    @viewController = nc
    @window.setRootViewController(@viewController)
    @window.makeKeyAndVisible
    
    currentURLString = NSUserDefaults.standardUserDefaults.objectForKey(CURRENT_MOVIE_KEY)
    if(!(currentURLString.nil? or currentURLString.empty?))
      vc.pushMovieWithURLString(currentURLString, animated:false)
    end
    
    return true
  end
end