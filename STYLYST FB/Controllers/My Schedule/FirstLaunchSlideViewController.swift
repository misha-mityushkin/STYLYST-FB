//
//  FirstLaunchSlideViewController.swift
//  STYLYST
//
//  Created by Michael Mityushkin on 2020-05-15.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit
import CoreLocation

class FirstLaunchSlideViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    var appointmentsVC: AppointmentsViewController?
    let locationManager = CLLocationManager()
    
    let typeOfSlide = [ //true = image and text, false = text and button
        true,
        true,
        true,
        false,
        false
    ]
    
    let slideImages = [
        K.Images.backgroundWithLogo,
        K.Images.backgroundWithLogo,
        K.Images.backgroundWithLogo,
        K.Images.backgroundWithLogo,
        K.Images.backgroundWithLogo
    ]
    
    let slideTexts = [ //these might be placed in different labels depending on the slide type
        "Welcome to STYLYST!\nThe app for all your style needs",
        "Find places near you that suite your style preferences",
        "Book appointments and pay right through the app",
        "Please enable location services to get the best results near you",
        "Press Get Started to proceed to the app"
    ]
    
    let buttonTexts = [
        "",
        "",
        "",
        "Enable",
        "Get Started"
    ]
    
//    let backGroundImages = [
//        K.Images.backgroundNoLogo,
//        K.Images.backgroundNoLogo,
//        K.Images.backgroundNoLogo,
//        K.Images.backgroundNoLogo,
//        K.Images.backgroundWithLogo
//    ]
    
    
    var slides: [Slide] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        scrollView.delegate = self
        
        
        slides = createSlides()
        setupSlideScrollView(slides: slides)
        pageControl.numberOfPages = slides.count
        pageControl.currentPage = 0
        view.bringSubviewToFront(pageControl)
    }
    
    
    func createSlides() -> [Slide] {
        var slides: [Slide] = []
        
        for i in 0 ..< slideImages.count {
            let slide:Slide = Bundle.main.loadNibNamed("SlideView", owner: self, options: nil)?.first as! Slide
            slide.firstLaunchVC = self
            if typeOfSlide[i] {
                slide.slideImage.isHidden = false
                slide.slideImage.image = slideImages[i]
                slide.slideImage.layer.masksToBounds = true
                slide.slideImage.layer.cornerRadius = 25
                
                slide.label1.isHidden = false
                slide.label1.text = slideTexts[i]
                
                slide.label2.isHidden = true
                
                slide.button.isHidden = true
            } else {
                slide.slideImage.isHidden = true
                
                slide.label1.isHidden = true
                
                slide.label2.isHidden = false
                slide.label2.text = slideTexts[i]
                
                slide.button.isHidden = false
                slide.button.setTitle(buttonTexts[i], for: slide.button.state)
                slide.button.layer.masksToBounds = true
                slide.button.layer.cornerRadius = 15
            }
            slides.append(slide)
        }
        
        return slides
    }
    
    
    func setupSlideScrollView(slides : [Slide]) {
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(slides.count), height: view.frame.height)
        scrollView.isPagingEnabled = true
        
        for i in 0 ..< slides.count {
            slides[i].frame = CGRect(x: view.frame.width * CGFloat(i), y: 0, width: view.frame.width, height: view.frame.height)
            scrollView.addSubview(slides[i])
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
        pageControl.currentPage = Int(pageIndex)
        
        
        
        let maximumHorizontalOffset: CGFloat = scrollView.contentSize.width - scrollView.frame.width
        let currentHorizontalOffset: CGFloat = scrollView.contentOffset.x
        
        // vertical
        let maximumVerticalOffset: CGFloat = scrollView.contentSize.height - scrollView.frame.height
        let currentVerticalOffset: CGFloat = scrollView.contentOffset.y
        
        let percentageHorizontalOffset: CGFloat = currentHorizontalOffset / maximumHorizontalOffset
        let percentageVerticalOffset: CGFloat = currentVerticalOffset / maximumVerticalOffset
        
        
        /*
         * below code changes the background color of view on paging the scrollview
         */
        //        self.scrollView(scrollView, didScrollToPercentageOffset: percentageHorizontalOffset)
        
        
        /*
         * below code scales the imageview on paging the scrollview
         */
        let percentOffset: CGPoint = CGPoint(x: percentageHorizontalOffset, y: percentageVerticalOffset)
        
        if(percentOffset.x > 0 && percentOffset.x <= 0.25) {
            
            slides[0].slideImage.transform = CGAffineTransform(scaleX: (0.25-percentOffset.x)/0.25, y: (0.25-percentOffset.x)/0.25)
            slides[1].slideImage.transform = CGAffineTransform(scaleX: percentOffset.x/0.25, y: percentOffset.x/0.25)
            
        } else if(percentOffset.x > 0.25 && percentOffset.x <= 0.50) {
            slides[1].slideImage.transform = CGAffineTransform(scaleX: (0.50-percentOffset.x)/0.25, y: (0.50-percentOffset.x)/0.25)
            slides[2].slideImage.transform = CGAffineTransform(scaleX: percentOffset.x/0.50, y: percentOffset.x/0.50)
            
        } else if(percentOffset.x > 0.50 && percentOffset.x <= 0.75) {
            slides[2].slideImage.transform = CGAffineTransform(scaleX: (0.75-percentOffset.x)/0.25, y: (0.75-percentOffset.x)/0.25)
            slides[3].slideImage.transform = CGAffineTransform(scaleX: percentOffset.x/0.75, y: percentOffset.x/0.75)
            
        } else if(percentOffset.x > 0.75 && percentOffset.x <= 1) {
            slides[3].slideImage.transform = CGAffineTransform(scaleX: (1-percentOffset.x)/0.25, y: (1-percentOffset.x)/0.25)
            slides[4].slideImage.transform = CGAffineTransform(scaleX: percentOffset.x, y: percentOffset.x)
        }
        
        if scrollView.contentOffset.y > 0 || scrollView.contentOffset.y < 0 {
           scrollView.contentOffset.y = 0
        }
    }
}

extension FirstLaunchSlideViewController: CLLocationManagerDelegate {
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            Alerts.showNoOptionAlert(title: "Location Services are disabled", message: "Go to Settings>Privacy>Location Services and enable Location Services", sender: appointmentsVC!)
        }
    }
    
    func checkLocationAuthorization() {
        print("in checkLocationAuthorization")
        switch CLLocationManager.authorizationStatus() {
            case .denied:
                print("denied")
                Alerts.showNoOptionAlert(title: "Please enable Location Services", message: "Go to Settings>Privacy>Location Services>STYLYST and tap \"While Using the App\"", sender: appointmentsVC!)
                break
            case .restricted:
                print("restricted")
                Alerts.showNoOptionAlert(title: "Location Services are Restricted", message: "Your device has active restrictions such as parental controls. Please contact your administrator to enable Location Services for this app", sender: appointmentsVC!)
                break
            case .notDetermined:
                print("notDetermined")
                locationManager.requestWhenInUseAuthorization()
                break
            case .authorizedAlways:
                print("always")
                fallthrough
            case .authorizedWhenInUse:
                print("case whenInUse")
                locationManager.startUpdatingLocation()
                break
            @unknown default:
                print("unknown case")
                break
        }
    }
}
