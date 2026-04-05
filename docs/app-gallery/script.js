// VedantaTrade App Gallery JavaScript
// Interactive features and functionality for the UI evolution showcase

// Initialize AOS (Animate On Scroll)
AOS.init({
    duration: 800,
    once: true,
    offset: 100,
    easing: 'ease-in-out',
    mirror: true
});

// Gallery State Management
const galleryState = {
    currentVersion: 'v37',
    carouselInstances: {},
    imageModal: null,
    isFullscreen: false,
    touchStartX: 0,
    touchEndX: 0
};

// Initialize carousels when DOM is ready
document.addEventListener('DOMContentLoaded', function() {
    initializeCarousels();
    setupImageModal();
    setupKeyboardNavigation();
    setupTouchGestures();
    setupAnalyticsTracking();
    setupLazyLoading();
});

// Initialize Bootstrap Carousels
function initializeCarousels() {
    const carousels = document.querySelectorAll('.carousel');
    
    carousels.forEach(carousel => {
        const id = carousel.id;
        galleryState.carouselInstances[id] = new bootstrap.Carousel(carousel, {
            interval: 5000,
            pause: 'hover',
            wrap: true,
            keyboard: false
        });
        
        // Add custom event listeners
        setupCarouselControls(carousel, id);
        setupCarouselIndicators(carousel, id);
    });
}

// Setup carousel controls with enhanced functionality
function setupCarouselControls(carousel, id) {
    const prevBtn = carousel.querySelector('.carousel-control-prev');
    const nextBtn = carousel.querySelector('.carousel-control-next');
    
    if (prevBtn) {
        prevBtn.addEventListener('click', (e) => {
            e.preventDefault();
            trackAnalytics('carousel_navigation', {
                direction: 'previous',
                version: id
            });
        });
    }
    
    if (nextBtn) {
        nextBtn.addEventListener('click', (e) => {
            e.preventDefault();
            trackAnalytics('carousel_navigation', {
                direction: 'next',
                version: id
            });
        });
    }
}

// Setup carousel indicators with custom styling
function setupCarouselIndicators(carousel, id) {
    const indicators = carousel.querySelectorAll('.carousel-indicators button');
    
    indicators.forEach((indicator, index) => {
        indicator.addEventListener('click', (e) => {
            e.preventDefault();
            trackAnalytics('carousel_indicator_click', {
                slide: index,
                version: id
            });
        });
        
        // Add hover effect
        indicator.addEventListener('mouseenter', () => {
            indicator.style.transform = 'scale(1.2)';
        });
        
        indicator.addEventListener('mouseleave', () => {
            indicator.style.transform = 'scale(1)';
        });
    });
}

// Setup image modal for fullscreen viewing
function setupImageModal() {
    const modal = document.getElementById('imageModal');
    const modalImage = document.getElementById('modalImage');
    
    if (modal && modalImage) {
        galleryState.imageModal = new bootstrap.Modal(modal, {
            keyboard: true,
            focus: true
        });
        
        // Handle image clicks
        document.addEventListener('click', (e) => {
            if (e.target.tagName === 'IMG' && e.target.dataset.bsToggle === 'modal') {
                e.preventDefault();
                openImageModal(e.target.src, e.target.alt);
            }
        });
        
        // Handle modal events
        modal.addEventListener('show.bs.modal', () => {
            trackAnalytics('image_modal_open', {
                image: modalImage.src
            });
        });
        
        modal.addEventListener('hidden.bs.modal', () => {
            trackAnalytics('image_modal_close');
        });
    }
}

// Open image modal with fullscreen option
function openImageModal(imageSrc, imageAlt) {
    const modalImage = document.getElementById('modalImage');
    if (modalImage) {
        modalImage.src = imageSrc;
        modalImage.alt = imageAlt;
        
        // Add fullscreen button
        addFullscreenButton(modalImage);
    }
}

// Add fullscreen button to modal
function addFullscreenButton(imageElement) {
    const modalBody = imageElement.parentElement;
    const fullscreenBtn = document.createElement('button');
    fullscreenBtn.className = 'btn btn-primary position-absolute top-0 end-0 m-3';
    fullscreenBtn.innerHTML = '<i class="bi bi-arrows-fullscreen"></i> Fullscreen';
    fullscreenBtn.onclick = () => toggleFullscreen(imageElement);
    
    modalBody.appendChild(fullscreenBtn);
}

// Toggle fullscreen for images
function toggleFullscreen(imageElement) {
    if (!galleryState.isFullscreen) {
        openFullscreen(imageElement);
    } else {
        closeFullscreen();
    }
}

// Open fullscreen mode
function openFullscreen(imageElement) {
    const fullscreenDiv = document.createElement('div');
    fullscreenDiv.id = 'fullscreen-viewer';
    fullscreenDiv.className = 'position-fixed top-0 start-0 w-100 h-100 d-flex align-items-center justify-content-center bg-dark';
    fullscreenDiv.style.zIndex = '9999';
    fullscreenDiv.style.cursor = 'zoom-out';
    
    const fullscreenImg = imageElement.cloneNode(true);
    fullscreenImg.className = 'img-fluid';
    fullscreenImg.style.maxHeight = '90vh';
    fullscreenImg.style.maxWidth = '90vw';
    
    fullscreenDiv.appendChild(fullscreenImg);
    document.body.appendChild(fullscreenDiv);
    
    galleryState.isFullscreen = true;
    
    // Add exit fullscreen handler
    fullscreenDiv.addEventListener('click', closeFullscreen);
    
    // Add ESC key handler
    document.addEventListener('keydown', (e) => {
        if (e.key === 'Escape' && galleryState.isFullscreen) {
            closeFullscreen();
        }
    });
    
    trackAnalytics('fullscreen_open');
}

// Close fullscreen mode
function closeFullscreen() {
    const fullscreenDiv = document.getElementById('fullscreen-viewer');
    if (fullscreenDiv) {
        fullscreenDiv.remove();
        galleryState.isFullscreen = false;
        trackAnalytics('fullscreen_close');
    }
}

// Setup keyboard navigation
function setupKeyboardNavigation() {
    document.addEventListener('keydown', (e) => {
        // Handle carousel navigation
        if (e.key === 'ArrowLeft') {
            navigateCarousel('prev');
        } else if (e.key === 'ArrowRight') {
            navigateCarousel('prev');
        }
        
        // Handle version tabs
        if (e.key === 'Tab' && !e.shiftKey) {
            e.preventDefault();
            navigateVersionTabs('next');
        } else if (e.key === 'Tab' && e.shiftKey) {
            e.preventDefault();
            navigateVersionTabs('prev');
        }
        
        // Handle modal close
        if (e.key === 'Escape' && galleryState.imageModal) {
            galleryState.imageModal.hide();
        }
    });
}

// Setup touch gestures for mobile
function setupTouchGestures() {
    let touchStartX = 0;
    let touchEndX = 0;
    
    document.addEventListener('touchstart', (e) => {
        touchStartX = e.changedTouches[0].screenX;
    });
    
    document.addEventListener('touchend', (e) => {
        touchEndX = e.changedTouches[0].screenX;
        handleSwipeGesture(touchStartX, touchEndX);
    });
}

// Handle swipe gestures
function handleSwipeGesture(startX, endX) {
    const diff = startX - endX;
    const threshold = 50;
    
    if (Math.abs(diff) > threshold) {
        if (diff > 0) {
            navigateCarousel('prev');
        } else {
            navigateCarousel('next');
        }
    }
}

// Navigate carousel programmatically
function navigateCarousel(direction) {
    const activeTab = document.querySelector('.version-tabs .nav-link.active');
    if (activeTab) {
        const targetId = activeTab.dataset.bsTarget;
        const carousel = galleryState.carouselInstances[targetId];
        
        if (carousel) {
            if (direction === 'prev') {
                carousel.prev();
            } else if (direction === 'next') {
                carousel.next();
            }
        }
    }
}

// Navigate version tabs programmatically
function navigateVersionTabs(direction) {
    const tabs = document.querySelectorAll('.version-tabs .nav-link');
    const activeTab = document.querySelector('.version-tabs .nav-link.active');
    
    if (tabs.length > 0 && activeTab) {
        const currentIndex = Array.from(tabs).indexOf(activeTab);
        let nextIndex;
        
        if (direction === 'next') {
            nextIndex = (currentIndex + 1) % tabs.length;
        } else if (direction === 'prev') {
            nextIndex = currentIndex === 0 ? tabs.length - 1 : currentIndex - 1;
        }
        
        tabs[nextIndex].click();
    }
}

// Setup analytics tracking
function setupAnalyticsTracking() {
    // Track version tab changes
    const versionTabs = document.querySelectorAll('.version-tabs .nav-link');
    versionTabs.forEach(tab => {
        tab.addEventListener('click', () => {
            const version = tab.textContent.trim();
            trackAnalytics('version_tab_change', {
                version: version
            });
        });
    });
    
    // Track feature interactions
    const featureCards = document.querySelectorAll('.feature-card');
    featureCards.forEach((card, index) => {
        card.addEventListener('click', () => {
            trackAnalytics('feature_card_click', {
                feature_index: index
            });
        });
    });
    
    // Track download button clicks
    const downloadButtons = document.querySelectorAll('.download-buttons .btn');
    downloadButtons.forEach(btn => {
        btn.addEventListener('click', () => {
            const platform = btn.textContent.trim();
            trackAnalytics('download_button_click', {
                platform: platform
            });
        });
    });
}

// Analytics tracking function
function trackAnalytics(event, data = {}) {
    // This would integrate with your analytics service
    console.log('Analytics Event:', event, data);
    
    // Example: Google Analytics 4
    if (typeof gtag !== 'undefined') {
        gtag('event', event, {
            event_category: 'gallery_interaction',
            event_label: JSON.stringify(data)
        });
    }
    
    // Example: Custom analytics
    if (typeof customAnalytics !== 'undefined') {
        customAnalytics.track(event, data);
    }
}

// Setup lazy loading for images
function setupLazyLoading() {
    const images = document.querySelectorAll('img[data-src]');
    
    const imageObserver = new IntersectionObserver((entries, observer) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const img = entry.target;
                img.src = img.dataset.src;
                img.classList.add('loaded');
                observer.unobserve(img);
            }
        });
    });
    
    images.forEach(img => imageObserver.observe(img));
}

// Setup smooth scrolling
function setupSmoothScrolling() {
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });
}

// Setup version comparison tool
function setupVersionComparison() {
    const comparisonItems = document.querySelectorAll('.comparison-item');
    
    comparisonItems.forEach(item => {
        item.addEventListener('mouseenter', () => {
            item.style.transform = 'scale(1.05)';
            item.style.boxShadow = '0 10px 30px rgba(0,0,0,0.2)';
        });
        
        item.addEventListener('mouseleave', () => {
            item.style.transform = 'scale(1)';
            item.style.boxShadow = '0 4px 8px rgba(0,0,0,0.1)';
        });
    });
}

// Setup performance monitoring
function setupPerformanceMonitoring() {
    // Monitor page load time
    window.addEventListener('load', () => {
        const loadTime = performance.timing.loadEventEnd - performance.timing.navigationStart;
        trackAnalytics('page_load_time', {
            load_time: loadTime
        });
    });
    
    // Monitor carousel performance
    const carousels = document.querySelectorAll('.carousel');
    carousels.forEach((carousel, index) => {
        const observer = new PerformanceObserver((list) => {
            list.getEntries().forEach(entry => {
                if (entry.entryType === 'measure') {
                    trackAnalytics('carousel_performance', {
                        carousel_id: index,
                        duration: entry.duration
                    });
                }
            });
        });
        
        observer.observe({ entryTypes: ['measure'] });
    });
}

// Setup error handling
function setupErrorHandling() {
    window.addEventListener('error', (e) => {
        trackAnalytics('javascript_error', {
            message: e.message,
            filename: e.filename,
            lineno: e.lineno,
            colno: e.colno
        });
    });
    
    // Handle image loading errors
    document.addEventListener('error', (e) => {
        if (e.target.tagName === 'IMG') {
            e.target.src = 'assets/images/placeholder.png';
            trackAnalytics('image_load_error', {
                src: e.target.src
            });
        }
    }, true);
}

// Initialize all features
function initializeGallery() {
    setupSmoothScrolling();
    setupVersionComparison();
    setupPerformanceMonitoring();
    setupErrorHandling();
    
    // Add loading states
    addLoadingStates();
    
    // Add progress indicators
    addProgressIndicators();
}

// Add loading states
function addLoadingStates() {
    const buttons = document.querySelectorAll('.btn');
    
    buttons.forEach(btn => {
        btn.addEventListener('click', () => {
            if (!btn.classList.contains('loading')) {
                btn.classList.add('loading');
                btn.disabled = true;
                
                // Simulate loading
                setTimeout(() => {
                    btn.classList.remove('loading');
                    btn.disabled = false;
                }, 2000);
            }
        });
    });
}

// Add progress indicators
function addProgressIndicators() {
    const sections = document.querySelectorAll('section');
    
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const progressIndicator = createProgressIndicator(entry.target.id);
                if (progressIndicator) {
                    entry.target.appendChild(progressIndicator);
                }
            }
        });
    }, { threshold: 0.1 });
    
    sections.forEach(section => observer.observe(section));
}

// Create progress indicator
function createProgressIndicator(sectionId) {
    const indicator = document.createElement('div');
    indicator.className = 'progress-indicator position-fixed top-0 start-0 w-100';
    indicator.style.height = '4px';
    indicator.style.background = 'linear-gradient(90deg, var(--primary-color), var(--secondary-color))';
    indicator.style.zIndex = '1000';
    indicator.style.transform = 'translateX(-100%)';
    indicator.style.transition = 'transform 0.3s ease';
    
    return indicator;
}

// Update progress indicator
function updateProgressIndicator(sectionId, progress) {
    const indicator = document.querySelector(`#${sectionId} .progress-indicator`);
    if (indicator) {
        indicator.style.transform = `translateX(${(progress - 1) * 100}%)`;
    }
}

// Export functions for external use
window.VedantaTradeGallery = {
    navigateCarousel,
    navigateVersionTabs,
    openImageModal,
    toggleFullscreen,
    trackAnalytics,
    initializeGallery
};

// Initialize gallery when ready
initializeGallery();
