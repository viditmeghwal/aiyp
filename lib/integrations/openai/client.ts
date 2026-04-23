export const openai = {
  chat: {
    completions: {
      // eslint-disable-next-line @typescript-eslint/no-unused-vars
      create: async (_params: unknown): Promise<never> => {
        throw new Error("Install openai package and set OPENAI_API_KEY");
      },
    },
  },
};
