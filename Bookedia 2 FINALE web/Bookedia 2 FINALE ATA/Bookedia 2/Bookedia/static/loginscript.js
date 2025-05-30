let slides = document.querySelectorAll('.slide');
let currentSlide = 0;
const slideInterval = setInterval(nextSlide, 1000);

function nextSlide() {
    slides[currentSlide].classList.remove('active');
    currentSlide = (currentSlide + 1) % slides.length;
    slides[currentSlide].classList.add('active');
}

const signupBtn = document.getElementById('signupBtn');
const backToLogin = document.getElementById('backToLogin');
const loginForm = document.getElementById('loginForm');
const signupForm = document.getElementById('signupForm');

signupBtn.addEventListener('click', () => {
    loginForm.style.display = 'none';
    signupForm.style.display = 'flex';
    signupForm.style.transform = 'scale(1)';
});

backToLogin.addEventListener('click', () => {
    signupForm.style.display = 'none';
    loginForm.style.display = 'flex';
});
