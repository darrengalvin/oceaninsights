/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './src/pages/**/*.{js,ts,jsx,tsx,mdx}',
    './src/components/**/*.{js,ts,jsx,tsx,mdx}',
    './src/app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        ocean: {
          50: '#f0f9ff',
          100: '#e0f2fe',
          200: '#bae6fd',
          300: '#7dd3fc',
          400: '#38bdf8',
          500: '#0ea5e9',
          600: '#0284c7',
          700: '#0369a1',
          800: '#075985',
          900: '#0c4a6e',
        },
        // Below the Surface marketing colors (matching App Store screenshots)
        landing: {
          bg: '#8E99AB',            // Muted blue-grey background
          bgDark: '#7D8899',        // Darker variant
          bgLight: '#9BA5B5',       // Lighter variant
        },
        // Below the Surface app colors (dark theme)
        app: {
          background: '#0D1520',    // deepOcean - main background
          card: '#131D2A',          // midnightBlue - cards
          cardLight: '#1A2634',     // slateDepth - lighter cards
          border: '#243447',        // steelBlue - borders
          borderAccent: '#1E3A5F',  // cardBorder - subtle blue
        },
        aqua: {
          DEFAULT: '#00D9C4',       // aquaGlow - primary accent
          dark: '#0891B2',          // deepTeal - secondary
          light: '#67E8F9',         // softCyan - highlights
        },
      },
    },
  },
  plugins: [],
}



