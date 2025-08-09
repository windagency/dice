import type { StorybookConfig } from "@storybook/react-vite";
import tsconfigPaths from "vite-tsconfig-paths";

const config: StorybookConfig = {
  core: {
    disableTelemetry: true, // 👈 Disables telemetry
  },
  framework: {
    name: "@storybook/react-vite",
    options: {},
  },
  stories: ["../src/**/*.mdx", "../src/**/*.stories.@(js|jsx|mjs|ts|tsx)"],
  addons: [
    "@storybook/addon-links",
    "@storybook/addon-essentials",
    "@storybook/addon-interactions",
  ],
  docs: {
    autodocs: "tag",
  },
  viteFinal: async (config) => {
    config.plugins = [
      ...(config.plugins || []),
      tsconfigPaths({
        loose: true,
        root: process.cwd(),
      }),
    ];

    // Use polling instead of file watching for Docker environments
    if (config.server) {
      config.server.watch = {
        ...config.server.watch,
        usePolling: true,
        interval: 1000,
        ignored: ["**/node_modules/**", "**/.pnpm-store/**", "**/dist/**"],
      };
    }
    return config;
  },
};

export default config;
