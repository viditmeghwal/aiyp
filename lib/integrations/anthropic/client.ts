export const anthropic = {
  messages: {
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    create: async (_params: unknown): Promise<never> => {
      throw new Error("Install @anthropic-ai/sdk and set ANTHROPIC_API_KEY");
    },
  },
};
