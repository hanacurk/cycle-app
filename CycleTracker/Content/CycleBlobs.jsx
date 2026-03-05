import { useState, useEffect } from "react";

const phases = [
  { name: "Menstrual", color: "#FFD8E0", accent: "#FF8FAB", blob: "#FFB8CC", label: "Period Phase" },
  { name: "Follicular", color: "#FFF5A0", accent: "#F0C830", blob: "#FFE860", label: "Follicular Phase" },
  { name: "Ovulation", color: "#C8E8F0", accent: "#7DD4E8", blob: "#A8D8F0", label: "Ovulation Phase" },
  { name: "Luteal", color: "#D8F0D8", accent: "#80C880", blob: "#A8E0A8", label: "Luteal Phase" },
];

const MenstrualBlob = ({ frame }) => {
  const sway = Math.sin(frame * 0.04) * 4;
  const squish = 1 + Math.sin(frame * 0.06) * 0.04;
  // droopy sad eyes, slight frown
  return (
    <g transform={`translate(0, ${sway}) scale(1, ${squish})`}>
      {/* Main blob body */}
      <ellipse cx="0" cy="8" rx="52" ry="48" fill="#FFB8CC" />
      <ellipse cx="-18" cy="-8" rx="22" ry="20" fill="#FFB8CC" />
      <ellipse cx="18" cy="-10" rx="20" ry="18" fill="#FFB8CC" />
      {/* Shine */}
      <ellipse cx="-14" cy="-18" rx="8" ry="6" fill="white" opacity="0.3" />
      {/* Droopy left eye */}
      <ellipse cx="-16" cy="2" rx="7" ry="5" fill="#1A1A2E" />
      <ellipse cx="-14" cy="0" rx="2" ry="2" fill="white" opacity="0.7" />
      {/* Droopy right eye */}
      <ellipse cx="16" cy="2" rx="7" ry="5" fill="#1A1A2E" />
      <ellipse cx="18" cy="0" rx="2" ry="2" fill="white" opacity="0.7" />
      {/* Sad eyebrows */}
      <path d="M -22 -6 Q -16 -10 -10 -7" fill="none" stroke="#1A1A2E" strokeWidth="2.5" strokeLinecap="round" />
      <path d="M 10 -7 Q 16 -10 22 -6" fill="none" stroke="#1A1A2E" strokeWidth="2.5" strokeLinecap="round" />
      {/* Sad mouth */}
      <path d="M -10 14 Q 0 10 10 14" fill="none" stroke="#1A1A2E" strokeWidth="2.5" strokeLinecap="round" />
      {/* Little tear */}
      <ellipse cx="-23" cy="10" rx="3" ry="4" fill="#A8C8F0" opacity="0.8" />
    </g>
  );
};

const FollicularBlob = ({ frame }) => {
  const bounce = Math.abs(Math.sin(frame * 0.05)) * 6;
  const squish = 1 - Math.abs(Math.sin(frame * 0.05)) * 0.06;
  return (
    <g transform={`translate(0, ${-bounce}) scale(1, ${squish})`}>
      {/* Main blob - slightly irregular */}
      <ellipse cx="0" cy="8" rx="50" ry="46" fill="#FFE860" />
      <ellipse cx="-20" cy="-6" rx="24" ry="20" fill="#FFE860" />
      <ellipse cx="16" cy="-12" rx="18" ry="16" fill="#FFE860" />
      {/* Shine */}
      <ellipse cx="-14" cy="-16" rx="9" ry="6" fill="white" opacity="0.35" />
      {/* Happy eyes - curved */}
      <path d="M -22 0 Q -16 -7 -10 0" fill="none" stroke="#1A1A2E" strokeWidth="3" strokeLinecap="round" />
      <path d="M 10 0 Q 16 -7 22 0" fill="none" stroke="#1A1A2E" strokeWidth="3" strokeLinecap="round" />
      {/* Big smile */}
      <path d="M -14 12 Q 0 22 14 12" fill="none" stroke="#1A1A2E" strokeWidth="2.5" strokeLinecap="round" />
      {/* Rosy cheeks */}
      <ellipse cx="-24" cy="10" rx="9" ry="6" fill="#FFB830" opacity="0.3" />
      <ellipse cx="24" cy="10" rx="9" ry="6" fill="#FFB830" opacity="0.3" />
      {/* Little sparkle */}
      <circle cx="34" cy="-20" r="3" fill="#F0C830" opacity={0.5 + Math.sin(frame * 0.1) * 0.5} />
      <circle cx="38" cy="-14" r="2" fill="#F0C830" opacity={0.5 + Math.cos(frame * 0.1) * 0.5} />
    </g>
  );
};

const OvulationBlob = ({ frame }) => {
  const float = Math.sin(frame * 0.05) * 5;
  const wiggle = Math.sin(frame * 0.08) * 3;
  return (
    <g transform={`translate(${wiggle * 0.3}, ${float})`}>
      {/* Main blob */}
      <ellipse cx="0" cy="8" rx="50" ry="46" fill="#A8D8F0" />
      <ellipse cx="-18" cy="-8" rx="22" ry="19" fill="#A8D8F0" />
      <ellipse cx="18" cy="-10" rx="20" ry="17" fill="#A8D8F0" />
      {/* Shine */}
      <ellipse cx="-12" cy="-16" rx="8" ry="6" fill="white" opacity="0.35" />
      {/* Heart eyes ♡ */}
      {/* Left heart */}
      <path d="M -20 -2 C -20 -6 -25 -6 -25 -2 C -25 1 -20 4 -20 4 C -20 4 -15 1 -15 -2 C -15 -6 -20 -6 -20 -2 Z"
        fill="#1A1A2E" />
      {/* Right heart */}
      <path d="M 20 -2 C 20 -6 15 -6 15 -2 C 15 1 20 4 20 4 C 20 4 25 1 25 -2 C 25 -6 20 -6 20 -2 Z"
        fill="#1A1A2E" />
      {/* Gentle smile */}
      <path d="M -12 13 Q 0 20 12 13" fill="none" stroke="#1A1A2E" strokeWidth="2.5" strokeLinecap="round" />
      {/* Rosy cheeks */}
      <ellipse cx="-26" cy="10" rx="9" ry="5" fill="#7DD4E8" opacity="0.4" />
      <ellipse cx="26" cy="10" rx="9" ry="5" fill="#7DD4E8" opacity="0.4" />
    </g>
  );
};

const LutealBlob = ({ frame }) => {
  const sway = Math.sin(frame * 0.03) * 3;
  const breathe = 1 + Math.sin(frame * 0.04) * 0.02;
  return (
    <g transform={`translate(${sway}, 0) scale(${breathe})`}>
      {/* Main blob */}
      <ellipse cx="0" cy="8" rx="51" ry="47" fill="#A8E0A8" />
      <ellipse cx="-19" cy="-7" rx="23" ry="19" fill="#A8E0A8" />
      <ellipse cx="17" cy="-11" rx="19" ry="17" fill="#A8E0A8" />
      {/* Shine */}
      <ellipse cx="-13" cy="-17" rx="8" ry="6" fill="white" opacity="0.3" />
      {/* Flat/neutral eyes */}
      <ellipse cx="-16" cy="1" rx="7" ry="6" fill="#1A1A2E" />
      <ellipse cx="-14" cy="-1" rx="2" ry="2" fill="white" opacity="0.7" />
      <ellipse cx="16" cy="1" rx="7" ry="6" fill="#1A1A2E" />
      <ellipse cx="18" cy="-1" rx="2" ry="2" fill="white" opacity="0.7" />
      {/* Flat/tired mouth - straight line */}
      <path d="M -10 14 Q 0 13 10 14" fill="none" stroke="#1A1A2E" strokeWidth="2.5" strokeLinecap="round" />
      {/* Little "–" expression marks */}
      <path d="M -24 -4 L -18 -4" stroke="#1A1A2E" strokeWidth="2" strokeLinecap="round" opacity="0.5" />
      <path d="M 18 -4 L 24 -4" stroke="#1A1A2E" strokeWidth="2" strokeLinecap="round" opacity="0.5" />
    </g>
  );
};

const BlobComponent = ({ phase, frame }) => {
  switch (phase.name) {
    case "Menstrual": return <MenstrualBlob frame={frame} />;
    case "Follicular": return <FollicularBlob frame={frame} />;
    case "Ovulation": return <OvulationBlob frame={frame} />;
    case "Luteal": return <LutealBlob frame={frame} />;
    default: return null;
  }
};

export default function App() {
  const [frame, setFrame] = useState(0);
  const [active, setActive] = useState(0);

  useEffect(() => {
    const interval = setInterval(() => setFrame(f => f + 1), 40);
    return () => clearInterval(interval);
  }, []);

  const phase = phases[active];

  return (
    <div style={{
      minHeight: "100vh",
      background: "#FFF0F4",
      display: "flex",
      flexDirection: "column",
      alignItems: "center",
      justifyContent: "center",
      fontFamily: "'Georgia', serif",
      gap: 32,
      padding: 24,
      transition: "background 0.6s ease",
    }}>

      <div style={{ textAlign: "center" }}>
        <div style={{ fontSize: 11, letterSpacing: 4, color: "#FF8FAB", textTransform: "uppercase", marginBottom: 6 }}>
          CycleTracker
        </div>
        <div style={{ fontSize: 22, fontWeight: "bold", color: "#1A1A2E" }}>Phase Blobs</div>
      </div>

      {/* Main blob display */}
      <div style={{
        background: phase.color,
        borderRadius: 40,
        padding: "48px 64px",
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        gap: 16,
        boxShadow: `0 12px 40px ${phase.accent}44`,
        transition: "background 0.5s ease, box-shadow 0.5s ease",
        minWidth: 260,
      }}>
        <svg width="130" height="130" viewBox="-65 -50 130 110" overflow="visible">
          <BlobComponent phase={phase} frame={frame} />
        </svg>
        <div style={{
          fontSize: 15,
          color: "#1A1A2E",
          opacity: 0.6,
          fontStyle: "italic",
          letterSpacing: 0.5,
        }}>{phase.label}</div>
      </div>

      {/* All four small previews */}
      <div style={{ display: "flex", gap: 16, flexWrap: "wrap", justifyContent: "center" }}>
        {phases.map((p, i) => (
          <button key={p.name} onClick={() => setActive(i)} style={{
            background: p.color,
            border: active === i ? `3px solid ${p.accent}` : "3px solid transparent",
            borderRadius: 24,
            padding: "12px 16px",
            cursor: "pointer",
            display: "flex",
            flexDirection: "column",
            alignItems: "center",
            gap: 8,
            boxShadow: active === i ? `0 4px 20px ${p.accent}66` : "0 2px 8px rgba(0,0,0,0.06)",
            transition: "all 0.3s ease",
            transform: active === i ? "translateY(-3px)" : "none",
          }}>
            <svg width="60" height="60" viewBox="-65 -50 130 110" overflow="visible">
              <BlobComponent phase={p} frame={frame} />
            </svg>
            <div style={{ fontSize: 10, color: "#1A1A2E", opacity: 0.6, letterSpacing: 0.5, fontFamily: "sans-serif" }}>
              {p.name}
            </div>
          </button>
        ))}
      </div>

      <div style={{ color: "rgba(26,26,46,0.3)", fontSize: 11, letterSpacing: 2, textTransform: "uppercase", fontFamily: "sans-serif" }}>
        tap to preview
      </div>
    </div>
  );
}
