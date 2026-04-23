export default function ProblemSection() {
  return (
    <section className="bg-pocket-peach py-24">
      <div className="mx-auto max-w-4xl px-6">
        <h2 className="font-display text-3xl font-bold italic text-ink-900 md:text-4xl">
          You started a business, not a marketing agency.
        </h2>
        <div className="mt-8 grid gap-8 md:grid-cols-2">
          <div>
            <p className="text-lg text-ink-700">
              Solo founders spend 60% of their week on brand tasks they didn&apos;t sign up
              for — writing captions, designing graphics, managing Google profiles,
              chasing reviews.
            </p>
            <p className="mt-4 text-lg text-ink-700">
              The result? Inconsistent presence, missed opportunities, and burnout
              before you even get to the work you love.
            </p>
          </div>
          <div className="space-y-4">
            {[
              "No brand voice or visual consistency",
              "Instagram goes quiet for weeks",
              "Google Business Profile full of unanswered reviews",
              "No time to create content that actually converts",
              "Agency quotes are $3k–$10k/month minimum",
            ].map((pain) => (
              <div key={pain} className="flex items-start gap-3">
                <span className="mt-1 h-2 w-2 shrink-0 rounded-full bg-pocket-orange" />
                <span className="text-ink-700">{pain}</span>
              </div>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}
