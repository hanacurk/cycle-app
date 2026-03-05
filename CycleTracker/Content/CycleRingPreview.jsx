import { useState, useEffect, useRef } from "react";

const PHASES = [
  { name: "Menstrual",  days: 5,  color: "#FF8FAB", light: "#FFD8E0" },
  { name: "Follicular", days: 9,  color: "#F0B429", light: "#FFF5A0" },
  { name: "Ovulation",  days: 4,  color: "#7DD4E8", light: "#C8E8F0" },
  { name: "Luteal",     days: 10, color: "#80C880", light: "#D8F0D8" },
];
const CYCLE_LENGTH = 28;

const toRad = deg => (deg * Math.PI) / 180;
const toDeg = rad => (rad * 180) / Math.PI;

function buildArcs(phases, total) {
  let arcs = [];
  let startDay = 1;
  for (const ph of phases) {
    const startAngle = ((startDay - 1) / total) * 360 - 90;
    const endAngle = ((startDay - 1 + ph.days) / total) * 360 - 90;
    arcs.push({ ...ph, startAngle, endAngle, startDay, endDay: startDay + ph.days - 1 });
    startDay += ph.days;
  }
  return arcs;
}

function arcPath(cx, cy, r, startDeg, endDeg) {
  const start = { x: cx + r * Math.cos(toRad(startDeg)), y: cy + r * Math.sin(toRad(startDeg)) };
  const end = { x: cx + r * Math.cos(toRad(endDeg)), y: cy + r * Math.sin(toRad(endDeg)) };
  const large = endDeg - startDeg > 180 ? 1 : 0;
  return `M ${start.x} ${start.y} A ${r} ${r} 0 ${large} 1 ${end.x} ${end.y}`;
}

export default function App() {
  const arcs = buildArcs(PHASES, CYCLE_LENGTH);
  const [currentDay, setCurrentDay] = useState(15);
  const [isDragging, setIsDragging] = useState(false);
  const ringRef = useRef(null);
  const cx = 150, cy = 150, r = 105;

  const currentPhase = arcs.find(a => currentDay >= a.startDay && currentDay <= a.endDay) || arcs[0];

  // Convert current day to angle for the indicator dot
  const indicatorAngle = ((currentDay - 1) / CYCLE_LENGTH) * 360 - 90;
  const dotX = cx + r * Math.cos(toRad(indicatorAngle));
  const dotY = cy + r * Math.sin(toRad(indicatorAngle));

  const getAngleFromEvent = (e, rect) => {
    const clientX = e.touches ? e.touches[0].clientX : e.clientX;
    const clientY = e.touches ? e.touches[0].clientY : e.clientY;
    const x = clientX - rect.left - cx;
    const y = clientY - rect.top - cy;
    return toDeg(Math.atan2(y, x));
  };

  const angleToDayRaw = angle => {
    let normalized = ((angle + 90) % 360 + 360) % 360;
    return Math.max(1, Math.min(CYCLE_LENGTH, Math.round((normalized / 360) * CYCLE_LENGTH) + 1));
  };

  const handleStart = e => {
    setIsDragging(true);
    e.preventDefault();
  };

  const handleMove = e => {
    if (!isDragging || !ringRef.current) return;
    const rect = ringRef.current.getBoundingClientRect();
    const angle = getAngleFromEvent(e, rect);
    const day = angleToDayRaw(angle);
    setCurrentDay(day);
  };

  const handleEnd = () => setIsDragging(false);

  // Week strip: 7 days centered on today (day 15 = "today" in demo)
  const TODAY_DAY = 15;
  const weekDays = Array.from({ length: 7 }, (_, i) => {
    const day = ((TODAY_DAY - 3 + i - 1 + CYCLE_LENGTH) % CYCLE_LENGTH) + 1;
    const phase = arcs.find(a => day >= a.startDay && day <= a.endDay) || arcs[0];
    return { day, phase, isToday: day === TODAY_DAY, isSelected: day === currentDay };
  });

  const dayLabels = ["S","M","T","W","T","F","S"];

  return (
    <div style={{
      minHeight: "100vh",
      background: currentPhase.light,
      display: "flex",
      flexDirection: "column",
      alignItems: "center",
      padding: "32px 24px",
      fontFamily: "-apple-system, 'SF Pro Rounded', sans-serif",
      gap: 24,
      transition: "background 0.5s ease",
    }}>

      {/* Header */}
      <div style={{ width: "100%", maxWidth: 340 }}>
        <div style={{ fontSize: 26, fontWeight: "800", color: "#1A1A2E" }}>
          Hello, <span style={{ color: "#1A1A2E" }}>Hana</span>
        </div>
        <div style={{ fontSize: 13, color: "#1A1A2E", opacity: 0.45, marginTop: 2 }}>
          {new Date().toLocaleDateString("en-GB", { day: "numeric", month: "long", year: "numeric" })}
        </div>
      </div>

      {/* Week strip */}
      <div style={{
        display: "flex",
        gap: 6,
        background: "rgba(255,255,255,0.5)",
        borderRadius: 20,
        padding: "10px 12px",
        width: "100%",
        maxWidth: 340,
        justifyContent: "space-between",
      }}>
        {weekDays.map(({ day, phase, isToday, isSelected }, i) => (
          <button key={i} onClick={() => setCurrentDay(day)} style={{
            display: "flex",
            flexDirection: "column",
            alignItems: "center",
            gap: 3,
            width: 40,
            padding: "8px 4px",
            borderRadius: 14,
            border: "none",
            background: isSelected
              ? phase.color
              : isToday
              ? phase.color + "33"
              : "transparent",
            cursor: "pointer",
            transition: "all 0.2s ease",
            boxShadow: isSelected ? `0 3px 10px ${phase.color}66` : "none",
          }}>
            <span style={{
              fontSize: 10,
              fontWeight: 600,
              color: isSelected ? "white" : "#1A1A2E",
              opacity: isSelected ? 1 : 0.4,
            }}>{dayLabels[i]}</span>
            <span style={{
              fontSize: 16,
              fontWeight: isSelected ? 700 : 400,
              color: isSelected ? "white" : "#1A1A2E",
            }}>{day < 10 ? "0" + day : day}</span>
            {isToday && !isSelected && (
              <div style={{ width: 4, height: 4, borderRadius: "50%", background: phase.color }} />
            )}
          </button>
        ))}
      </div>

      {/* Ring */}
      <div style={{ position: "relative" }}>
        <svg
          ref={ringRef}
          width={300}
          height={300}
          onMouseDown={handleStart}
          onMouseMove={handleMove}
          onMouseUp={handleEnd}
          onMouseLeave={handleEnd}
          onTouchStart={handleStart}
          onTouchMove={handleMove}
          onTouchEnd={handleEnd}
          style={{ cursor: isDragging ? "grabbing" : "grab", userSelect: "none" }}
        >
          {/* White circle bg */}
          <circle cx={cx} cy={cy} r={130} fill="white" opacity={0.55} />

          {/* Track */}
          <circle cx={cx} cy={cy} r={r} fill="none" stroke="white" strokeWidth={22} opacity={0.7} />

          {/* Phase arcs */}
          {arcs.map((arc, i) => (
            <path
              key={i}
              d={arcPath(cx, cy, r, arc.startAngle + 0.8, arc.endAngle - 0.8)}
              fill="none"
              stroke={arc.color}
              strokeWidth={20}
              strokeLinecap="round"
              opacity={0.9}
            />
          ))}

          {/* Indicator dot */}
          <circle
            cx={dotX}
            cy={dotY}
            r={12}
            fill="white"
            stroke={currentPhase.color}
            strokeWidth={3}
            style={{ filter: `drop-shadow(0 2px 6px ${currentPhase.color}88)` }}
          />
          <circle cx={dotX} cy={dotY} r={5} fill={currentPhase.color} />

          {/* Center content */}
          <text x={cx} y={cy - 28} textAnchor="middle" fontSize={42} fontWeight="800"
            fill="#1A1A2E" fontFamily="-apple-system, sans-serif">
            {currentDay}
          </text>
          <text x={cx} y={cy + 6} textAnchor="middle" fontSize={13} fontWeight="500"
            fill="#1A1A2E" opacity={0.5} fontFamily="-apple-system, sans-serif">
            {currentPhase.name} Phase
          </text>

          {/* Drag hint */}
          <text x={cx} y={cy + 28} textAnchor="middle" fontSize={10}
            fill="#1A1A2E" opacity={0.3} fontFamily="-apple-system, sans-serif">
            drag to explore
          </text>
        </svg>
      </div>

      {/* Phase legend */}
      <div style={{ display: "flex", gap: 16, flexWrap: "wrap", justifyContent: "center" }}>
        {arcs.map(arc => (
          <div key={arc.name} style={{ display: "flex", alignItems: "center", gap: 5 }}>
            <div style={{ width: 8, height: 8, borderRadius: "50%", background: arc.color }} />
            <span style={{ fontSize: 12, color: "#1A1A2E", opacity: 0.55, fontFamily: "sans-serif" }}>
              {arc.name}
            </span>
          </div>
        ))}
      </div>

      {/* Log button */}
      <button style={{
        width: "100%",
        maxWidth: 340,
        padding: "14px",
        borderRadius: 18,
        border: "1.5px solid rgba(255,255,255,0.8)",
        background: "rgba(255,255,255,0.5)",
        fontSize: 15,
        fontWeight: 600,
        color: "#1A1A2E",
        cursor: "pointer",
        fontFamily: "sans-serif",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        gap: 6,
      }}>
        Log Period <span style={{ fontSize: 18, lineHeight: 1 }}>+</span>
      </button>

      {/* Info cards */}
      <div style={{ width: "100%", maxWidth: 340, display: "flex", flexDirection: "column", gap: 10 }}>
        <div style={{ display: "flex", gap: 10 }}>
          {[
            { icon: "📅", title: "Next Period", value: `${CYCLE_LENGTH - currentDay + 1} days` },
            { icon: "🌿", title: "Phase Day", value: `Day ${currentDay - currentPhase.startDay + 1}` },
          ].map(card => (
            <div key={card.title} style={{
              flex: 1,
              background: "rgba(255,255,255,0.55)",
              borderRadius: 18,
              padding: "14px 16px",
              display: "flex",
              alignItems: "center",
              gap: 10,
            }}>
              <div style={{
                width: 36, height: 36, borderRadius: "50%",
                background: currentPhase.color + "25",
                display: "flex", alignItems: "center", justifyContent: "center",
                fontSize: 16,
              }}>{card.icon}</div>
              <div>
                <div style={{ fontSize: 10, color: "#1A1A2E", opacity: 0.45, fontFamily: "sans-serif" }}>{card.title}</div>
                <div style={{ fontSize: 15, fontWeight: 700, color: "#1A1A2E", fontFamily: "sans-serif" }}>{card.value}</div>
              </div>
            </div>
          ))}
        </div>

        {/* Pregnancy chance */}
        <div style={{
          background: "rgba(255,255,255,0.55)",
          borderRadius: 18,
          padding: "14px 18px",
          display: "flex",
          alignItems: "center",
          gap: 12,
        }}>
          <div style={{
            width: 36, height: 36, borderRadius: "50%",
            background: currentPhase.color + "25",
            display: "flex", alignItems: "center", justifyContent: "center",
            fontSize: 16,
          }}>🌸</div>
          <span style={{ fontSize: 15, fontWeight: 500, color: "#1A1A2E", fontFamily: "sans-serif", flex: 1 }}>
            Chances of Pregnancy
          </span>
          <div style={{ display: "flex", alignItems: "center", gap: 5 }}>
            <div style={{
              width: 8, height: 8, borderRadius: "50%",
              background: currentPhase.name === "Ovulation" ? "#4CAF50"
                : currentPhase.name === "Follicular" ? "#FF9800" : "#9E9E9E"
            }} />
            <span style={{
              fontSize: 13, fontWeight: 700, fontFamily: "sans-serif",
              color: currentPhase.name === "Ovulation" ? "#4CAF50"
                : currentPhase.name === "Follicular" ? "#FF9800" : "#9E9E9E"
            }}>
              {currentPhase.name === "Ovulation" ? "High"
                : currentPhase.name === "Follicular" ? "Medium" : "Low"}
            </span>
          </div>
        </div>
      </div>

    </div>
  );
}
