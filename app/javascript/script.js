document.addEventListener('DOMContentLoaded', function() {
    // Theme toggle functionality
    const themeToggle = document.getElementById('themeToggle');
    const themeText = document.getElementById('themeText');
    const body = document.body;

    // Check for saved theme preference or default to 'light'
    const currentTheme = localStorage.getItem('theme') || 'light';
    
    // Apply the theme on page load
    if (currentTheme === 'dark') {
        body.setAttribute('data-theme', 'dark');
        themeToggle.classList.add('dark');
        themeText.textContent = 'Dark';
    }
    themeToggle.addEventListener('click', function() {
        if (body.getAttribute('data-theme') === 'dark') {
            // Switch to light mode
            body.removeAttribute('data-theme');
            themeToggle.classList.remove('dark');
            themeText.textContent = 'Light';
            localStorage.setItem('theme', 'light');
        } else {
            // Switch to dark mode
            body.setAttribute('data-theme', 'dark');
            themeToggle.classList.add('dark');
            themeText.textContent = 'Dark';
            localStorage.setItem('theme', 'dark');
        }
    });
});

let canSave = true;
let editor = null;