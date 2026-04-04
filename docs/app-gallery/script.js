// VedantaTrade App Gallery JavaScript

// Initialize AOS (Animate On Scroll)
AOS.init({
    duration: 800,
    once: true,
    offset: 100
});

// Global variables
let currentVersion = 'v34';
let carouselInstances = {};

// Initialize when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
    initializeApp();
});

function initializeApp() {
    // Initialize carousels
    initializeCarousels();
    
    // Initialize version tabs
    initializeVersionTabs();
    
    // Initialize smooth scrolling
    initializeSmoothScrolling();
    
    // Initialize download functionality
    initializeDownload();
    
    // Initialize keyboard navigation
    initializeKeyboardNavigation();
    
    // Initialize analytics
    initializeAnalytics();
}

function initializeCarousels() {
    // Initialize all carousels
    const carousels = document.querySelectorAll('.carousel');
    carousels.forEach(carousel => {
        const id = carousel.id;
        if (id) {
            carouselInstances[id] = new bootstrap.Carousel(carousel, {
                interval: 5000,
                pause: 'hover',
                wrap: true
            });
        }
    });
}

function initializeVersionTabs() {
    const versionTabs = document.querySelectorAll('#versionTabs button');
    versionTabs.forEach(tab => {
        tab.addEventListener('shown.bs.tab', function(e) {
            const target = e.target.getAttribute('data-bs-target');
            currentVersion = target.replace('#', '');
            
            // Reinitialize AOS for new content
            AOS.refresh();
            
            // Track version change
            trackVersionChange(currentVersion);
            
            // Update URL hash
            updateURLHash(currentVersion);
        });
    });
    
    // Check URL hash for initial version
    const hash = window.location.hash.substring(1);
    if (hash && ['v34', 'v33', 'v32', 'v31', 'v30'].includes(hash)) {
        const tab = document.querySelector(`#${hash}-tab`);
        if (tab) {
            bootstrap.Tab.getOrCreateInstance(tab).show();
        }
    }
}

function initializeSmoothScrolling() {
    // Smooth scroll for anchor links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function(e) {
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

function initializeDownload() {
    // Add download functionality
    const downloadButtons = document.querySelectorAll('[onclick*="downloadApp"]');
    downloadButtons.forEach(button => {
        button.addEventListener('click', function(e) {
            e.preventDefault();
            handleDownload(this);
        });
    });
}

function handleDownload(button) {
    // Show loading state
    const originalText = button.innerHTML;
    button.innerHTML = '<i class="bi bi-hourglass-split"></i> Loading...';
    button.disabled = true;
    
    // Simulate download process
    setTimeout(() => {
        // Determine download type based on button content
        let downloadType = 'web';
        if (button.innerHTML.includes('Google Play')) {
            downloadType = 'android';
        } else if (button.innerHTML.includes('App Store')) {
            downloadType = 'ios';
        }
        
        // Track download
        trackDownload(downloadType);
        
        // Show success message
        showNotification('Download started! Check your device for the VedantaTrade app.', 'success');
        
        // Reset button
        button.innerHTML = originalText;
        button.disabled = false;
        
        // Open download link (in real implementation)
        openDownloadLink(downloadType);
    }, 1500);
}

function openDownloadLink(type) {
    const downloadUrls = {
        android: 'https://play.google.com/store/apps/details?id=com.vedantatrade',
        ios: 'https://apps.apple.com/app/vedantatrade',
        web: 'https://app.vedantatrade.com.np'
    };
    
    if (downloadUrls[type]) {
        window.open(downloadUrls[type], '_blank');
    }
}

function initializeKeyboardNavigation() {
    // Keyboard navigation for carousels
    document.addEventListener('keydown', function(e) {
        if (e.key === 'ArrowLeft' || e.key === 'ArrowRight') {
            const activeCarousel = document.querySelector('.carousel.active');
            if (activeCarousel) {
                const carouselId = activeCarousel.id;
                if (carouselInstances[carouselId]) {
                    if (e.key === 'ArrowLeft') {
                        carouselInstances[carouselId].prev();
                    } else {
                        carouselInstances[carouselId].next();
                    }
                }
            }
        }
    });
}

function initializeAnalytics() {
    // Track page view
    trackPageView();
    
    // Track user interactions
    trackUserInteractions();
}

function trackPageView() {
    // In real implementation, this would send to analytics service
    console.log('Page view tracked:', {
        page: 'app-gallery',
        version: currentVersion,
        timestamp: new Date().toISOString()
    });
}

function trackVersionChange(version) {
    console.log('Version change tracked:', {
        from: currentVersion,
        to: version,
        timestamp: new Date().toISOString()
    });
}

function trackDownload(type) {
    console.log('Download tracked:', {
        type: type,
        version: currentVersion,
        timestamp: new Date().toISOString()
    });
}

function trackUserInteractions() {
    // Track clicks on screenshots
    document.querySelectorAll('.screenshot-container img').forEach(img => {
        img.addEventListener('click', function() {
            openFullscreenImage(this.src);
            trackImageClick(this.src);
        });
    });
    
    // Track carousel interactions
    document.querySelectorAll('.carousel').forEach(carousel => {
        carousel.addEventListener('slide.bs.carousel', function(e) {
            trackCarouselSlide(e.target.id, e.to);
        });
    });
}

function trackImageClick(imageSrc) {
    console.log('Image click tracked:', {
        image: imageSrc,
        version: currentVersion,
        timestamp: new Date().toISOString()
    });
}

function trackCarouselSlide(carouselId, slideIndex) {
    console.log('Carousel slide tracked:', {
        carousel: carouselId,
        slide: slideIndex,
        version: currentVersion,
        timestamp: new Date().toISOString()
    });
}

function openFullscreenImage(imageSrc) {
    // Create modal for fullscreen image view
    const modal = document.createElement('div');
    modal.className = 'fullscreen-image-modal';
    modal.innerHTML = `
        <div class="fullscreen-image-overlay" onclick="closeFullscreenImage()">
            <div class="fullscreen-image-container">
                <img src="${imageSrc}" alt="Fullscreen Screenshot" class="fullscreen-image">
                <button class="close-button" onclick="closeFullscreenImage()">
                    <i class="bi bi-x-lg"></i>
                </button>
                <div class="image-controls">
                    <button class="control-button" onclick="zoomImage(1.2)">
                        <i class="bi bi-zoom-in"></i>
                    </button>
                    <button class="control-button" onclick="zoomImage(0.8)">
                        <i class="bi bi-zoom-out"></i>
                    </button>
                    <button class="control-button" onclick="resetZoom()">
                        <i class="bi bi-arrows-fullscreen"></i>
                    </button>
                </div>
            </div>
        </div>
    `;
    
    document.body.appendChild(modal);
    
    // Add styles
    const styles = document.createElement('style');
    styles.textContent = `
        .fullscreen-image-modal {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            z-index: 9999;
            background: rgba(0, 0, 0, 0.9);
            display: flex;
            align-items: center;
            justify-content: center;
            animation: fadeIn 0.3s ease;
        }
        
        .fullscreen-image-overlay {
            width: 100%;
            height: 100%;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
        }
        
        .fullscreen-image-container {
            position: relative;
            max-width: 90%;
            max-height: 90%;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .fullscreen-image {
            max-width: 100%;
            max-height: 100%;
            object-fit: contain;
            border-radius: 10px;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.5);
            transition: transform 0.3s ease;
        }
        
        .close-button {
            position: absolute;
            top: -40px;
            right: 0;
            background: rgba(255, 255, 255, 0.2);
            border: none;
            color: white;
            font-size: 1.5rem;
            padding: 8px 12px;
            border-radius: 5px;
            cursor: pointer;
            transition: background 0.3s ease;
        }
        
        .close-button:hover {
            background: rgba(255, 255, 255, 0.3);
        }
        
        .image-controls {
            position: absolute;
            bottom: -40px;
            left: 50%;
            transform: translateX(-50%);
            display: flex;
            gap: 10px;
        }
        
        .control-button {
            background: rgba(255, 255, 255, 0.2);
            border: none;
            color: white;
            padding: 8px 12px;
            border-radius: 5px;
            cursor: pointer;
            transition: background 0.3s ease;
        }
        
        .control-button:hover {
            background: rgba(255, 255, 255, 0.3);
        }
        
        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }
    `;
    document.head.appendChild(styles);
    
    // Add escape key listener
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') {
            closeFullscreenImage();
        }
    });
}

function closeFullscreenImage() {
    const modal = document.querySelector('.fullscreen-image-modal');
    if (modal) {
        modal.remove();
        document.removeEventListener('keydown', closeFullscreenImage);
    }
}

let currentZoom = 1;

function zoomImage(factor) {
    currentZoom *= factor;
    currentZoom = Math.max(0.5, Math.min(3, currentZoom));
    
    const img = document.querySelector('.fullscreen-image');
    if (img) {
        img.style.transform = `scale(${currentZoom})`;
    }
}

function resetZoom() {
    currentZoom = 1;
    const img = document.querySelector('.fullscreen-image');
    if (img) {
        img.style.transform = 'scale(1)';
    }
}

function scrollToGallery() {
    const gallery = document.getElementById('gallery');
    if (gallery) {
        gallery.scrollIntoView({
            behavior: 'smooth',
            block: 'start'
        });
    }
}

function updateURLHash(version) {
    const url = new URL(window.location);
    url.hash = version;
    window.history.replaceState({}, '', url);
}

function showNotification(message, type = 'info') {
    // Create notification element
    const notification = document.createElement('div');
    notification.className = `notification notification-${type}`;
    notification.innerHTML = `
        <div class="notification-content">
            <i class="bi bi-${getNotificationIcon(type)}"></i>
            <span>${message}</span>
            <button class="notification-close" onclick="closeNotification(this)">
                <i class="bi bi-x"></i>
            </button>
        </div>
    `;
    
    // Add styles
    const styles = document.createElement('style');
    styles.textContent = `
        .notification {
            position: fixed;
            top: 20px;
            right: 20px;
            z-index: 10000;
            min-width: 300px;
            max-width: 500px;
            animation: slideInRight 0.3s ease;
        }
        
        .notification-content {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 15px;
            border-radius: 8px;
            color: white;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
        }
        
        .notification-success .notification-content {
            background: #27ae60;
        }
        
        .notification-error .notification-content {
            background: #e74c3c;
        }
        
        .notification-info .notification-content {
            background: #3498db;
        }
        
        .notification-warning .notification-content {
            background: #f39c12;
        }
        
        .notification-close {
            background: none;
            border: none;
            color: white;
            cursor: pointer;
            padding: 0;
            margin-left: auto;
        }
        
        @keyframes slideInRight {
            from {
                transform: translateX(100%);
                opacity: 0;
            }
            to {
                transform: translateX(0);
                opacity: 1;
            }
        }
        
        @keyframes slideOutRight {
            from {
                transform: translateX(0);
                opacity: 1;
            }
            to {
                transform: translateX(100%);
                opacity: 0;
            }
        }
    `;
    
    if (!document.querySelector('#notification-styles')) {
        styles.id = 'notification-styles';
        document.head.appendChild(styles);
    }
    
    document.body.appendChild(notification);
    
    // Auto-remove after 5 seconds
    setTimeout(() => {
        if (notification.parentNode) {
            notification.style.animation = 'slideOutRight 0.3s ease';
            setTimeout(() => {
                notification.remove();
            }, 300);
        }
    }, 5000);
}

function getNotificationIcon(type) {
    const icons = {
        success: 'check-circle',
        error: 'x-circle',
        info: 'info-circle',
        warning: 'exclamation-triangle'
    };
    return icons[type] || 'info-circle';
}

function closeNotification(button) {
    const notification = button.closest('.notification');
    if (notification) {
        notification.style.animation = 'slideOutRight 0.3s ease';
        setTimeout(() => {
            notification.remove();
        }, 300);
    }
}

// Utility functions
function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

function throttle(func, limit) {
    let inThrottle;
    return function() {
        const args = arguments;
        const context = this;
        if (!inThrottle) {
            func.apply(context, args);
            inThrottle = true;
            setTimeout(() => inThrottle = false, limit);
        }
    };
}

// Performance optimization
const optimizeScroll = debounce(() => {
    // Optimize scroll performance
    requestAnimationFrame(() => {
        // Add scroll-based animations if needed
    });
}, 10);

window.addEventListener('scroll', optimizeScroll);

// Preload images for better performance
function preloadImages() {
    const imageUrls = [
        'assets/images/v34/dashboard.png',
        'assets/images/v34/vat-returns.png',
        'assets/images/v34/expense-reconciliation.png',
        'assets/images/v34/inventory-management.png',
        'assets/images/v34/checkout-system.png'
    ];
    
    imageUrls.forEach(url => {
        const img = new Image();
        img.src = url;
    });
}

// Initialize preloading
preloadImages();

// Export functions for external use
window.VedantaTradeGallery = {
    scrollToGallery,
    showNotification,
    openFullscreenImage,
    closeFullscreenImage,
    trackVersionChange,
    trackDownload
};
