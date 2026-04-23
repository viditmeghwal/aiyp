import {
  Body,
  Button,
  Container,
  Head,
  Heading,
  Html,
  Preview,
  Section,
  Text,
} from "@react-email/components";

interface CheckoutSuccessEmailProps {
  name: string;
  planName: string;
  appUrl: string;
}

export function CheckoutSuccessEmail({
  name,
  planName,
  appUrl,
}: CheckoutSuccessEmailProps) {
  return (
    <Html>
      <Head />
      <Preview>
        You&apos;re now on the {planName} plan — welcome to the full experience
      </Preview>
      <Body style={{ backgroundColor: "#FFF8F1", fontFamily: "sans-serif" }}>
        <Container style={{ maxWidth: 600, margin: "0 auto", padding: "40px 20px" }}>
          <Heading style={{ color: "#F97316", fontSize: 28, fontWeight: 700 }}>
            Agency in Your Pocket
          </Heading>
          <Text style={{ color: "#334155", fontSize: 16, lineHeight: "1.6" }}>
            Hi {name},
          </Text>
          <Text style={{ color: "#334155", fontSize: 16, lineHeight: "1.6" }}>
            You&apos;re now on the <strong>{planName}</strong> plan. Your full workflow
            library is unlocked — go build something brilliant.
          </Text>
          <Section style={{ textAlign: "center", margin: "32px 0" }}>
            <Button
              href={`${appUrl}/dashboard`}
              style={{
                backgroundColor: "#F97316",
                color: "#ffffff",
                padding: "14px 28px",
                borderRadius: "8px",
                fontWeight: 600,
                fontSize: 16,
                textDecoration: "none",
              }}
            >
              Go to your dashboard →
            </Button>
          </Section>
          <Text style={{ color: "#64748B", fontSize: 14 }}>
            — The Agency in Your Pocket team
          </Text>
        </Container>
      </Body>
    </Html>
  );
}
