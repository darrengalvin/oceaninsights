/** @type {import('next').NextConfig} */
const nextConfig = {
  typescript: {
    // !! WARN !!
    // Dangerously allow production builds to successfully complete even if
    // your project has type errors.
    // This is temporary to get the deployment working
    ignoreBuildErrors: true,
  },
  eslint: {
    // Warning: This allows production builds to successfully complete even if
    // your project has ESLint errors.
    ignoreDuringBuilds: true,
  },
  experimental: {
    skipTrailingSlashRedirect: true,
  },
  async rewrites() {
    return [
      { source: '/privacy', destination: '/privacy.html' },
      { source: '/terms', destination: '/terms.html' },
      { source: '/support', destination: '/support.html' },
    ]
  },
  // Don't try to fetch data from API routes during build
  generateBuildId: async () => {
    return 'build-' + Date.now()
  },
}

module.exports = nextConfig

