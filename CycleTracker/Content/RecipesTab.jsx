import { useState, useEffect } from "react";

const phases = [
  {
    name: "Menstrual",
    color: "#FFD8E0",
    accent: "#FF8FAB",
    blob: "#FFB8CC",
    label: "Menstrual Phase",
    tagline: "Warm & nourishing",
    foods: ["Dark Chocolate", "Ginger Tea", "Lentil Soup"],
    foodEmoji: ["🍫", "🫖", "🍲"],
    foodColors: ["#5C3A1E", "#C8943A", "#E8702A"],
    tip: "Iron-rich foods help replenish what you lose",
  },
  {
    name: "Follicular",
    color: "#FFF5A0",
    accent: "#F0C830",
    blob: "#FFE860",
    label: "Follicular Phase",
    tagline: "Light & energising",
    foods: ["Avocado Toast", "Berry Smoothie", "Quinoa Bowl"],
    foodEmoji: ["🥑", "🫐", "🥗"],
    foodColors: ["#4A7A3A", "#6A48C8", "#5A9A4A"],
    tip: "Estrogen is rising — light, fresh foods support energy",
  },
  {
    name: "Ovulation",
    color: "#C8E8F0",
    accent: "#7DD4E8",
    blob: "#A8D8F0",
    label: "Ovulation Phase",
    tagline: "Fresh & vibrant",
    foods: ["Salmon", "Spinach Salad", "Watermelon"],
    foodEmoji: ["🐟", "🥬", "🍉"],
    foodColors: ["#E86848", "#3A8A3A", "#E84858"],
    tip: "Anti-inflammatory foods support peak fertility",
  },
  {
    name: "Luteal",
    color: "#D8F0D8",
    accent: "#80C880",
    blob: "#A8E0A8",
    label: "Luteal Phase",
    tagline: "Comforting & grounding",
    foods: ["Sweet Potato", "Chamomile Tea", "Oat Porridge"],
    foodEmoji: ["🍠", "🌼", "🥣"],
    foodColors: ["#C86820", "#C8A830", "#C8904A"],
    tip: "Complex carbs ease PMS and stabilise mood",
  },
];

// Chef hat component
const ChefHat = ({ color = "white" }) => (
  <g>
    <ellipse cx="0" cy="2" rx="16" ry="5" fill={color} />
    <ellipse cx="0" cy="-8" rx="12" ry="10" fill={color} />
    <ellipse cx="-7" cy="-4" rx="5" ry="7" fill={color} />
    <ellipse cx="7" cy="-4" rx="5" ry="7" fill={color} />
    <rect x="-13" y="0" width="26" height="6" rx="2" fill={color} />
    <rect x="-13" y="3" width="26" height="3" rx="1" fill="rgba(0,0,0,0.08)" />
  </g>
);

// Spoon component
const Spoon = ({ x = 0, y = 0, rotation = 0, color = "#C8943A" }) => (
  <g transform={`translate(${x}, ${y}) rotate(${rotation})`}>
    <ellipse cx="0" cy="-18" rx="5" ry="6" fill={color} />
    <rect x="-1.5" y="-12" width="3" height="22" rx="1.5" fill={color} />
  </g>
);

const CookingBlob = ({ phase, frame }) => {
  const float = Math.sin(frame * 0.04) * 3;
  const stir = Math.sin(frame * 0.08) * 15;
  const blobColor = phase.blob;
  const accent = phase.accent;

  // Different expressions per phase
  const getEyes = () => {
    switch (phase.name) {
      case "Menstrual":
        return (
          <g>
            <ellipse cx="-14" cy="4" rx="6" ry="5" fill="#1A1A2E" />
            <ellipse cx="-12" cy="2" rx="2" ry="2" fill="white" opacity="0.7" />
            <ellipse cx="14" cy="4" rx="6" ry="5" fill="#1A1A2E" />
            <ellipse cx="16" cy="2" rx="2" ry="2" fill="white" opacity="0.7" />
            <path d="M -8 14 Q 0 10 8 14" fill="none" stroke="#1A1A2E" strokeWidth="2" strokeLinecap="round" />
          </g>
        );
      case "Follicular":
        return (
          <g>
            <path d="M -20 2 Q -14 -5 -8 2" fill="none" stroke="#1A1A2E" strokeWidth="2.5" strokeLinecap="round" />
            <path d="M 8 2 Q 14 -5 20 2" fill="none" stroke="#1A1A2E" strokeWidth="2.5" strokeLinecap="round" />
            <path d="M -10 14 Q 0 22 10 14" fill="none" stroke="#1A1A2E" strokeWidth="2.5" strokeLinecap="round" />
            <ellipse cx="-22" cy="10" rx="8" ry="5" fill={accent} opacity="0.3" />
            <ellipse cx="22" cy="10" rx="8" ry="5" fill={accent} opacity="0.3" />
          </g>
        );
      case "Ovulation":
        return (
          <g>
            <path d="M -24 0 C -24 -5 -29 -5 -29 0 C -29 3 -24 6 -24 6 C -24 6 -19 3 -19 0 C -19 -5 -24 -5 -24 0 Z" fill="#1A1A2E" />
            <path d="M 24 0 C 24 -5 19 -5 19 0 C 19 3 24 6 24 6 C 24 6 29 3 29 0 C 29 -5 24 -5 24 0 Z" fill="#1A1A2E" />
            <path d="M -10 14 Q 0 20 10 14" fill="none" stroke="#1A1A2E" strokeWidth="2.5" strokeLinecap="round" />
            <ellipse cx="-28" cy="12" rx="8" ry="5" fill={accent} opacity="0.35" />
            <ellipse cx="28" cy="12" rx="8" ry="5" fill={accent} opacity="0.35" />
          </g>
        );
      case "Luteal":
        return (
          <g>
            <ellipse cx="-14" cy="3" rx="6" ry="5" fill="#1A1A2E" />
            <ellipse cx="-12" cy="1" rx="2" ry="2" fill="white" opacity="0.7" />
            <ellipse cx="14" cy="3" rx="6" ry="5" fill="#1A1A2E" />
            <ellipse cx="16" cy="1" rx="2" ry="2" fill="white" opacity="0.7" />
            <path d="M -8 14 Q 0 13 8 14" fill="none" stroke="#1A1A2E" strokeWidth="2" strokeLinecap="round" />
          </g>
        );
      default: return null;
    }
  };

  return (
    <g transform={`translate(0, ${float})`}>
      {/* Blob body */}
      <ellipse cx="0" cy="14" rx="50" ry="44" fill={blobColor} />
      <ellipse cx="-18" cy="-2" rx="22" ry="19" fill={blobColor} />
      <ellipse cx="18" cy="-4" rx="20" ry="17" fill={blobColor} />
      {/* Shine */}
      <ellipse cx="-12" cy="-10" rx="8" ry="5" fill="white" opacity="0.3" />
      {/* Eyes & mouth */}
      {getEyes()}
      {/* Chef hat */}
      <g transform="translate(0, -46)">
        <ChefHat color="white" />
      </g>
      {/* Tiny spoon being stirred */}
      <g transform={`translate(42, 10) rotate(${stir})`}>
        <Spoon x={0} y={0} rotation={20} color={accent} />
      </g>
      {/* Little steam puffs */}
      <circle cx="48" cy={-8 + Math.sin(frame * 0.06) * 3} r="4" fill="white" opacity={0.4 + Math.sin(frame * 0.08) * 0.2} />
      <circle cx="54" cy={-16 + Math.sin(frame * 0.06 + 1) * 3} r="3" fill="white" opacity={0.3 + Math.sin(frame * 0.07) * 0.2} />
      <circle cx="50" cy={-24 + Math.sin(frame * 0.05 + 2) * 3} r="2" fill="white" opacity={0.2 + Math.sin(frame * 0.06) * 0.15} />
    </g>
  );
};

// Food illustration card
const FoodCard = ({ emoji, name, color, phase, index, frame }) => {
  const bob = Math.sin(frame * 0.05 + index * 1.2) * 3;
  return (
    <div style={{
      background: "white",
      borderRadius: 20,
      padding: "16px 20px",
      display: "flex",
      alignItems: "center",
      gap: 14,
      boxShadow: "0 4px 16px rgba(0,0,0,0.06)",
      transform: `translateY(${bob}px)`,
      transition: "transform 0.1s ease",
      flex: "1 1 140px",
    }}>
      <div style={{
        width: 44,
        height: 44,
        borderRadius: 14,
        background: phase.color,
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        fontSize: 22,
        flexShrink: 0,
      }}>{emoji}</div>
      <div>
        <div style={{ fontSize: 13, fontWeight: "bold", color: "#1A1A2E", fontFamily: "sans-serif" }}>{name}</div>
        <div style={{ fontSize: 10, color: color, fontFamily: "sans-serif", marginTop: 2, fontWeight: "600" }}>
          {phase.name}
        </div>
      </div>
    </div>
  );
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
      background: phase.color,
      display: "flex",
      flexDirection: "column",
      alignItems: "center",
      padding: "40px 24px",
      fontFamily: "Georgia, serif",
      gap: 28,
      transition: "background 0.6s ease",
    }}>

      {/* Header */}
      <div style={{ textAlign: "center" }}>
        <div style={{ fontSize: 11, letterSpacing: 4, color: phase.accent, textTransform: "uppercase", marginBottom: 6, fontFamily: "sans-serif", transition: "color 0.5s" }}>
          Recipes Tab
        </div>
        <div style={{ fontSize: 24, fontWeight: "bold", color: "#1A1A2E" }}>What to eat</div>
        <div style={{ fontSize: 13, color: "#1A1A2E", opacity: 0.5, marginTop: 4, fontStyle: "italic" }}>{phase.tagline}</div>
      </div>

      {/* Phase tabs */}
      <div style={{ display: "flex", gap: 8, flexWrap: "wrap", justifyContent: "center" }}>
        {phases.map((p, i) => (
          <button key={p.name} onClick={() => setActive(i)} style={{
            padding: "8px 16px",
            borderRadius: 20,
            border: "none",
            background: active === i ? "#1A1A2E" : "rgba(26,26,46,0.08)",
            color: active === i ? "white" : "#1A1A2E",
            cursor: "pointer",
            fontSize: 12,
            fontFamily: "sans-serif",
            fontWeight: active === i ? "bold" : "normal",
            transition: "all 0.3s ease",
          }}>{p.name}</button>
        ))}
      </div>

      {/* Cooking blob */}
      <div style={{
        background: "rgba(255,255,255,0.5)",
        borderRadius: 36,
        padding: "32px 48px",
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        gap: 12,
        boxShadow: `0 8px 32px ${phase.accent}33`,
        backdropFilter: "blur(8px)",
        transition: "box-shadow 0.5s ease",
      }}>
        <svg width="140" height="140" viewBox="-80 -70 160 140" overflow="visible">
          <CookingBlob phase={phase} frame={frame} />
        </svg>
        <div style={{
          fontSize: 12,
          color: "#1A1A2E",
          opacity: 0.5,
          fontStyle: "italic",
          fontFamily: "sans-serif",
          textAlign: "center",
          maxWidth: 200,
        }}>{phase.tip}</div>
      </div>

      {/* Food recommendation cards */}
      <div style={{ width: "100%", maxWidth: 500 }}>
        <div style={{ fontSize: 12, fontFamily: "sans-serif", color: "#1A1A2E", opacity: 0.5, letterSpacing: 2, textTransform: "uppercase", marginBottom: 12, textAlign: "center" }}>
          Recommended for you
        </div>
        <div style={{ display: "flex", gap: 12, flexWrap: "wrap", justifyContent: "center" }}>
          {phase.foods.map((food, i) => (
            <FoodCard
              key={food}
              emoji={phase.foodEmoji[i]}
              name={food}
              color={phase.foodColors[i]}
              phase={phase}
              index={i}
              frame={frame}
            />
          ))}
        </div>
      </div>

    </div>
  );
}
