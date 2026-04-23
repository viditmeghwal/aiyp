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

interface FreeAuditReadyEmailProps {
  name: string;
  businessName: string;
  score: number;
  auditUrl: string;
}

export function FreeAuditReadyEmail({
  name,
  businessName,
  score,
  auditUrl,
}: FreeAuditReadyEmailProps) {
  return (
    <Html>
      <Head />
      <Preview>Your free brand audit for {businessName} is ready</Preview>
      <Body style={{ backgroundColor: "#FFF8F1", fontFamily: "sans-serif" }}>
        <Container style={{ maxWidth: 600, margin: "0 auto", padding: "40px 20px" }}>
          <Heading style={{ color: "#F97316", fontSize: 28, fontWeight: 700 }}>
            Agency in Your Pocket
          </Heading>
          <Text style={{ color: "#334155", fontSize: 16, lineHeight: "1.6" }}>
            Hi {name},
          </Text>
          <Text style={{ color: "#334155", fontSize: 16, lineHeight: "1.6" }}>
            Your free brand audit for <strong>{businessName}</strong> is ready.
          </Text>
          <div
            style={{
              backgroundColor: "#FFE4D6",
              borderRadius: 12,
              padding: "24px",
              textAlign: "center",
              margin: "24px 0",
            }}
          >
            <Text
              style={{
                color: "#0F172A",
                fontSize: 48,
                fontWeight: 700,
                margin: "0",
                lineHeight: "1",
              }}
            >
              {score}/100
            </Text>
            <Text style={{ color: "#334155", margin: "8px 0 0" }}>
              Overall Brand Score
            </Text>
          </div>
          <Section style={{ textAlign: "center", margin: "32px 0" }}>
            <Button
              href={auditUrl}
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
              View your full audit →
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
