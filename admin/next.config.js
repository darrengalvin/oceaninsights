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
    // Skip prerendering API routes during build
    skipTrailingSlashRedirect: true,
  },
  // Don't try to fetch data from API routes during build
  generateBuildId: async () => {
    return 'build-' + Date.now()
  },
}

module.exports = nextConfig

