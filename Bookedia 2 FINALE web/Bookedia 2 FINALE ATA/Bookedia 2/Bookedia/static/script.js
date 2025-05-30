// Set the scroll amount (adjust as needed)
const scrollAmount = 200; // pixels to scroll

// Selecting the elements for the pages
const bookspage = document.getElementById('bookspage');
const homepage = document.getElementById('homepage');
const magazinespage = document.getElementById('magazinespage');
const musicpage = document.getElementById('musicpage');
const moviespage = document.getElementById('moviespage');
const gamingpage = document.getElementById('gamingpage');
const educpage = document.getElementById('educpage');

// Selecting the elements for the frames
const buyerHomeFrame = document.querySelector('.buyer_home_frame');
const booksFrame = document.querySelector('.books_frame');
const magazinesFrame = document.querySelector('.magazines_frame');
const musicFrame = document.querySelector('.music_frame');
const moviesFrame = document.querySelector('.movies_frame');
const gamingFrame = document.querySelector('.gaming_frame');
const educFrame = document.querySelector('.educ_frame');

// Helper function to initialize arrow functionality for a specific frame
function initializeArrows(frameClass) {
  const leftArrow = document.querySelector(`.${frameClass} .left-arrow`);
  const rightArrow = document.querySelector(`.${frameClass} .right-arrow`);
  const productContainer = document.querySelector(`.${frameClass} .products`);

  if (leftArrow && rightArrow && productContainer) {
    leftArrow.addEventListener('click', () => {
      productContainer.scrollBy({
        left: -scrollAmount,
        behavior: 'smooth',
      });
    });

    rightArrow.addEventListener('click', () => {
      productContainer.scrollBy({
        left: scrollAmount,
        behavior: 'smooth',
      });
    });
  }
}

// Function to switch pages and manage visibility of frames
function switchPage(frameToShow) {
  const allFrames = [
    buyerHomeFrame, booksFrame, magazinesFrame,
    musicFrame, moviesFrame, gamingFrame, educFrame
  ];

  // Hide all frames
  allFrames.forEach(frame => frame.style.display = 'none');

  // Show the selected frame
  frameToShow.style.display = 'block';

  // Initialize arrows for the currently visible frame
  initializeArrows(frameToShow.className);
}

// Event listener for homepage
homepage.addEventListener('click', function(event) {
  event.preventDefault();
  switchPage(buyerHomeFrame);
});

// Event listener for bookspage
bookspage.addEventListener('click', function(event) {
  event.preventDefault();
  switchPage(booksFrame);
});

// Event listener for magazinespage
magazinespage.addEventListener('click', function(event) {
  event.preventDefault();
  switchPage(magazinesFrame);
});

// Event listener for musicpage
musicpage.addEventListener('click', function(event) {
  event.preventDefault();
  switchPage(musicFrame);
});

// Event listener for moviespage
moviespage.addEventListener('click', function(event) {
  event.preventDefault();
  switchPage(moviesFrame);
});

// Event listener for gamingpage
gamingpage.addEventListener('click', function(event) {
  event.preventDefault();
  switchPage(gamingFrame);
});

// Event listener for educpage
educpage.addEventListener('click', function(event) {
  event.preventDefault();
  switchPage(educFrame);
});

// Smooth scroll for navigation
document.querySelectorAll('nav a').forEach(anchor => {
  anchor.addEventListener('click', function(e) {
    e.preventDefault();

    const targetId = this.getAttribute('href');
    const targetElement = document.querySelector(targetId);

    window.scrollTo({
      top: targetElement.offsetTop - 150, // Adjust according to your navbar height
      behavior: 'smooth'
    });
  });
});

// Initially show the home page
window.onload = () => switchPage(buyerHomeFrame);

const leftArrow2 = document.querySelector('.left-arrow2');
const rightArrow2 = document.querySelector('.right-arrow2');
const productContainer2 = document.querySelector('.topproducts');


leftArrow2.addEventListener('click', () => {
  productContainer2.scrollBy({ left: -200, behavior: 'smooth' });
});

rightArrow2.addEventListener('click', () => {
  productContainer2.scrollBy({ left: 200, behavior: 'smooth' });
});