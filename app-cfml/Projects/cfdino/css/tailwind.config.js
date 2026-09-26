/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["../**/*.{cfm,html}"],
  theme: {
    extend: {
      colors: {
        primary: '#0066CC',
        secondary: '#FF6B35',
        dark: '#1a202c',
        pink: '#0066CC'
      }
    }
  },
  plugins: []
}
