
function scrollToSection(sectionId) {
    const section = document.getElementById(sectionId);
    if (section) {
        // Get the height of the fixed header
        const headerOffset = document.querySelector('.top_header').offsetHeight;
        
        // Calculate the position of the section
        const elementPosition = section.getBoundingClientRect().top + window.scrollY;
        
        // Scroll to the section with the header offset
        window.scrollTo({
            top: elementPosition - headerOffset, // Adjusted for the header
            behavior: 'smooth'
        });
    }
}

document.addEventListener("DOMContentLoaded", () => {
    // Add a 'loaded' class to body after the page has fully loaded
    document.body.classList.add("loaded");

    // Add smooth transition effect when navigating away from the page
    const links = document.querySelectorAll("a"); // Select all links
    const transitionOverlay = document.querySelector(".transition-overlay");

    links.forEach(link => {
        link.addEventListener("click", (event) => {
            event.preventDefault(); // Prevent default link behavior
            const href = event.target.href;

            // Activate the overlay
            transitionOverlay.classList.add("active");

            // After the transition ends, redirect to the next page
            setTimeout(() => {
                window.location.href = href;
            }, 800); // Adjust delay to match the CSS transition time
        });
    });
});

