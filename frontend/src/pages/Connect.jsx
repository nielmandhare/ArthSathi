import { useMemo, useState } from 'react';
import { useSearchParams } from 'react-router-dom';
import { motion } from 'framer-motion';
import { MapPin, Landmark, MessageCircle, ExternalLink, Navigation } from 'lucide-react';
import { toast } from 'sonner';
import { PARTNERS, IMG } from '../data/mock';
import { PageWrap, Reveal, Stagger, staggerItem } from '../components/motion';
import { PageHeader, TrustNote, ExtBadge } from '../components/widgets';

const TYPE_CLS = { Bank: 'bg-pine text-white', NBFC: 'bg-clay text-white', MFI: 'bg-warning text-ink', SCA: 'bg-success text-white' };
const ADPLIST_URL = process.env.REACT_APP_ADPLIST_URL || '';

const DEMO_MENTORS = [
  { id: 'demo-m1', name: 'Aarav Mehta', domain: 'MSME Finance', expertise: 'Cash-flow planning · loan documentation · bank readiness', experience: '12 years supporting small manufacturing businesses', email: 'aarav.mehta@example.com', avatar: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?auto=format&fit=crop&w=320&q=80' },
  { id: 'demo-m2', name: 'Nisha Kulkarni', domain: 'Retail & Brand Strategy', expertise: 'Pricing · customer retention · local-to-online growth', experience: '10 years building Indian retail and D2C businesses', email: 'nisha.kulkarni@example.com', avatar: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=320&q=80' },
  { id: 'demo-m3', name: 'Rohan Iyer', domain: 'Digital Operations', expertise: 'Digital payments · inventory · business process setup', experience: '9 years helping micro-enterprises adopt practical technology', email: 'rohan.iyer@example.com', avatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=320&q=80' },
  { id: 'demo-m4', name: 'Kavya Deshmukh', domain: 'Women Entrepreneurship', expertise: 'Business planning · SHG operations · confidence building', experience: '14 years mentoring women-led enterprises across Maharashtra', email: 'kavya.deshmukh@example.com', avatar: 'https://images.unsplash.com/photo-1580489944761-15a19d654956?auto=format&fit=crop&w=320&q=80' },
];

// Fictional demo locations for the Connect experience; these are not official
// government or scheme-authorized partner locations.
const DEMO_PARTNER_LOCATIONS = {
  'sbi-shivajinagar': { address: 'Demo location, Shivajinagar, Pune', latitude: 18.5308, longitude: 73.8475, category: 'Demo bank' },
  'mavim-pune': { address: 'Demo location, Deccan Gymkhana, Pune', latitude: 18.5167, longitude: 73.8383, category: 'Demo SCA' },
  'bom-deccan': { address: 'Demo location, Deccan Gymkhana, Pune', latitude: 18.5133, longitude: 73.8395, category: 'Demo bank' },
  'tata-capital': { address: 'Demo location, FC Road, Pune', latitude: 18.5236, longitude: 73.8417, category: 'Demo NBFC' },
  'annapurna-mfi': { address: 'Demo location, Kothrud, Pune', latitude: 18.5074, longitude: 73.8077, category: 'Demo MFI' },
};

const MAP_BOUNDS = { west: 73.79, east: 73.89, south: 18.48, north: 18.58 };
const mapPosition = ({ latitude, longitude }) => ({
  left: `${((longitude - MAP_BOUNDS.west) / (MAP_BOUNDS.east - MAP_BOUNDS.west)) * 100}%`,
  top: `${((MAP_BOUNDS.north - latitude) / (MAP_BOUNDS.north - MAP_BOUNDS.south)) * 100}%`,
});

function googleMapsUrl({ name, address, latitude, longitude }) {
  return `https://www.google.com/maps/search/?api=1&query=${encodeURIComponent(`${name}, ${address}`)}&query_place_id=&center=${latitude},${longitude}`;
}

function PartnerMap({ partners, active, setActive }) {
  return (
    <div className="relative h-[380px] overflow-hidden rounded-3xl bg-sand lg:h-full lg:min-h-[560px]" data-testid="partner-map" role="region" aria-label="Pune map showing fictional demo partner locations">
      <iframe title="Pune map" className="absolute inset-0 h-full w-full border-0" src="https://www.openstreetmap.org/export/embed.html?bbox=73.79%2C18.48%2C73.89%2C18.58&layer=mapnik" />
      <div className="pointer-events-none absolute inset-0 bg-pine/5" />
      <span className="absolute left-[58%] top-[49%] flex -translate-x-1/2 -translate-y-1/2 flex-col items-center" aria-hidden>
        <span className="rounded-full bg-sand px-2.5 py-1 text-[10px] font-bold text-pine shadow-lg">You · Shivajinagar</span>
        <span className="mt-1 h-3.5 w-3.5 rounded-full border-2 border-white bg-clay shadow" />
      </span>
      {partners.map((p) => (
        <button
          key={p.id}
          onClick={() => setActive(p.id)}
          data-testid={`map-pin-${p.id}`}
          aria-label={`${p.name}, ${p.address}`}
          className="group pointer-events-auto absolute -translate-x-1/2 -translate-y-1/2"
          style={mapPosition(p)}
        >
          <span className={`relative flex h-9 w-9 items-center justify-center rounded-full border-2 shadow-lg transition-transform duration-300 group-hover:scale-110 ${active === p.id ? 'border-white bg-clay text-white scale-110' : 'border-pine bg-sand text-pine'}`}>
            <Landmark size={15} />
          </span>
          {active === p.id && (
            <motion.span initial={{ opacity: 0, y: 6 }} animate={{ opacity: 1, y: 0 }} className="absolute left-1/2 top-full z-10 mt-2 w-44 -translate-x-1/2 rounded-xl bg-white p-3 text-left shadow-xl">
              <span className="block text-xs font-bold text-ink">{p.name}</span>
              <span className="mt-0.5 block text-[11px] text-sage">{p.category} · Demo location</span>
            </motion.span>
          )}
        </button>
      ))}
    </div>
  );
}

function Partners() {
  const partners = useMemo(() => PARTNERS.map((partner) => ({ ...partner, ...DEMO_PARTNER_LOCATIONS[partner.id] })), []);
  const [active, setActive] = useState(partners[0].id);
  const activePartner = useMemo(() => partners.find((p) => p.id === active), [partners, active]);
  return (
    <div className="grid gap-6 lg:grid-cols-[1.15fr_1fr]">
      <Reveal><PartnerMap partners={partners} active={active} setActive={setActive} /></Reveal>
      <div className="space-y-4">
        <Stagger className="space-y-4" gap={0.06}>
          {partners.map((p) => (
            <motion.button
              variants={staggerItem}
              key={p.id}
              onClick={() => setActive(p.id)}
              data-testid={`partner-card-${p.id}`}
              className={`card-premium w-full p-5 text-left transition-[border-color,box-shadow] duration-300 ${active === p.id ? '!border-pine shadow-[0_0_0_2px_#0A3B2C]' : 'hover:border-pine/30'}`}
            >
              <div className="flex items-start justify-between gap-3">
                <div>
                  <div className="flex flex-wrap items-center gap-2">
                    <h3 className="font-display text-[15px] font-bold">{p.name}</h3>
                    <span className="rounded-full bg-sand px-2.5 py-0.5 text-[10px] font-bold uppercase tracking-[0.1em] text-sage">Fictional demo</span>
                    {p.recommended && <span className="rounded-full bg-clay/10 px-2.5 py-0.5 text-[10px] font-bold uppercase tracking-[0.1em] text-clay">Recommended</span>}
                  </div>
                  <p className="mt-1 flex items-center gap-2 text-xs text-sage"><MapPin size={12} /> {p.area} · {p.distance} away</p>
                </div>
                <span className={`rounded-full px-3 py-1 text-[10px] font-bold uppercase tracking-[0.1em] ${TYPE_CLS[p.type]}`}>{p.type}</span>
              </div>
              <p className="mt-3 text-xs text-sage">Demo profile · Supports: {p.schemes.length} of your schemes · <span className="font-semibold text-ink">{p.capacity}</span></p>
            </motion.button>
          ))}
        </Stagger>
        {activePartner && (
          <Reveal className="card-premium border-pine/20 bg-sand p-5" data-testid="partner-why">
            <p className="eyebrow mb-2 flex items-center gap-1.5"><Navigation size={12} /> Why {activePartner.recommended ? 'this partner' : 'it may fit'}</p>
            <ul className="space-y-1.5 text-[13px] text-pine">
              {activePartner.reasons.map((r) => <li key={r} className="flex items-start gap-2"><span className="mt-1.5 h-1.5 w-1.5 shrink-0 rounded-full bg-clay" />{r}</li>)}
            </ul>
            <button
              onClick={() => window.open(googleMapsUrl(activePartner), '_blank', 'noopener,noreferrer')}
              className="btn-primary mt-4 w-full !h-11"
              data-testid="partner-approach-btn"
            >
              View / approach demo location <ExternalLink size={14} />
            </button>
          </Reveal>
        )}
        <TrustNote tone="info">These partner profiles and locations are fictional demo data for navigation testing, not government-authorized partner listings.</TrustNote>
      </div>
    </div>
  );
}

function Mentors() {
  const [selectedMentor, setSelectedMentor] = useState(null);
  const [message, setMessage] = useState('');
  return (
    <div className="space-y-8">
      <div className="grid gap-8 lg:grid-cols-[1fr_360px]">
        <Stagger className="grid gap-5 sm:grid-cols-2">
          {DEMO_MENTORS.map((m) => (
            <motion.div variants={staggerItem} key={m.id} className="card-premium group p-6" data-testid={`mentor-card-${m.id}`}>
              <div className="flex items-center gap-4">
                <div className="img-frame h-14 w-14 rounded-full border-2 border-sand">
                  <img src={m.avatar} alt={m.name} loading="lazy" />
                </div>
                <div>
                  <h3 className="font-display text-[15px] font-bold">{m.name}</h3>
                  <p className="text-xs font-semibold text-clay">{m.domain}</p>
                </div>
              </div>
              <p className="mt-4 text-[13px] leading-relaxed text-sage"><strong className="text-ink/80">Expertise:</strong> {m.expertise}</p>
              <p className="mt-1.5 text-[13px] leading-relaxed text-sage"><strong className="text-ink/80">Experience:</strong> {m.experience}</p>
              <button
                onClick={() => { setSelectedMentor(m); setMessage(''); }}
                className="btn-ghost mt-5 w-full !h-11 !text-[13px]"
                data-testid={`mentor-connect-${m.id}`}
              >
                <MessageCircle size={14} /> Connect / message
              </button>
            </motion.div>
          ))}
        </Stagger>
        <Reveal className="img-frame hidden self-start overflow-hidden rounded-3xl lg:block">
          <img src={IMG.hero} alt="Experienced Indian shop owner who mentors new entrepreneurs" className="aspect-[3/4]" loading="lazy" />
        </Reveal>
      </div>
      <TrustNote>These are fictional demo profiles for exploring the contact flow, not government employees or official representatives.</TrustNote>
      {selectedMentor && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-ink/50 p-4" role="dialog" aria-modal="true" aria-label={`Contact ${selectedMentor.name}`}>
          <div className="card-premium w-full max-w-lg bg-white p-6 sm:p-8">
            <div className="flex items-center gap-4">
              <img src={selectedMentor.avatar} alt={selectedMentor.name} className="h-16 w-16 rounded-full object-cover" />
              <div><h2 className="font-display text-xl font-bold">Contact {selectedMentor.name}</h2><p className="text-sm font-semibold text-clay">{selectedMentor.domain}</p></div>
            </div>
            <p className="mt-4 text-sm text-sage">{selectedMentor.expertise}. {selectedMentor.experience}.</p>
            <p className="mt-2 text-sm text-sage">Demo email: <strong className="text-ink">{selectedMentor.email}</strong></p>
            <textarea value={message} onChange={(event) => setMessage(event.target.value)} placeholder="Write a demo message" className="mt-5 min-h-28 w-full rounded-xl border border-border p-3 text-sm outline-none focus:border-pine focus:ring-2 focus:ring-pine/15" data-testid="mentor-message-input" />
            <div className="mt-4 flex justify-end gap-2">
              <button onClick={() => setSelectedMentor(null)} className="btn-ghost">Close</button>
              <button onClick={() => toast('Demo message prepared', { description: 'No message was delivered. A messaging backend is not configured.' })} className="btn-primary" data-testid="mentor-send-btn">Send demo message</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

function AdpList() {
  return (
    <div className="space-y-8">
      <div className="card-premium flex flex-col gap-4 border-clay/30 bg-clay/5 p-6 sm:flex-row sm:items-center sm:justify-between" data-testid="adplist-banner">
        <div>
          <div className="flex flex-wrap items-center gap-3">
            <h3 className="font-display text-lg font-bold">Broader mentoring via ADPList</h3>
            <ExtBadge name="ADPList" />
          </div>
          <p className="mt-1.5 max-w-xl text-sm text-sage">ADPList is an external mentoring service. The portal destination must be configured before booking can open.</p>
          <button
            onClick={() => ADPLIST_URL ? window.open(ADPLIST_URL, '_blank', 'noopener,noreferrer') : toast('ADPList destination is not configured', { description: 'Set REACT_APP_ADPLIST_URL to enable the external portal link.' })}
            className="btn-primary shrink-0"
            disabled={!ADPLIST_URL}
            data-testid="adplist-open-btn"
          >
            Open ADPList <ExternalLink size={14} />
          </button>
        </div>
      </div>
      <TrustNote>ArthSathi does not host or represent ADPList. Booking, profiles and availability are handled entirely on the configured external portal.</TrustNote>
    </div>
  );
}

export default function Connect() {
  const [params, setParams] = useSearchParams();
  const tab = params.get('tab') || 'partners';
  const TABS = [
    { id: 'partners', label: 'Channel Partners' },
    { id: 'mentors', label: 'Domain Mentors' },
    { id: 'adplist', label: 'ADPList' },
  ];
  return (
    <PageWrap>
      <PageHeader
        eyebrow="Steps 10–12 · Humans & doorways"
        title="Know where to go, and who can help."
        desc="Find participating banks, SCAs, NBFCs and MFIs near you — then talk to people who have done this before."
        step="partner"
      />
      <section className="container-x mt-10">
        <div className="mb-8 flex w-max items-center gap-1 rounded-full border border-border bg-white p-1.5" role="tablist">
          {TABS.map((t) => (
            <button
              key={t.id}
              role="tab"
              aria-selected={tab === t.id}
              onClick={() => setParams({ tab: t.id })}
              data-testid={`connect-tab-${t.id}`}
              className={`rounded-full px-5 py-2.5 text-[13px] font-semibold transition-colors ${tab === t.id ? 'bg-pine text-white' : 'text-sage hover:text-ink'}`}
            >
              {t.label}
            </button>
          ))}
        </div>
        {tab === 'partners' && <Partners />}
        {tab === 'mentors' && <Mentors />}
        {tab === 'adplist' && <AdpList />}
      </section>
    </PageWrap>
  );
}
