import { useEffect, useMemo, useState } from 'react';
import { Link } from 'react-router-dom';
import { motion, AnimatePresence } from 'framer-motion';
import { Search, SlidersHorizontal, Mic, GitCompareArrows, X } from 'lucide-react';
import { inr, IMG } from '../data/mock';
import { fetchRecommendations, RecommendationApiError } from '../api/recommendations';
import { PageWrap, Reveal, Stagger, staggerItem } from '../components/motion';
import { PageHeader, TrustNote } from '../components/widgets';
import { useApp } from '../context/AppContext';

const FILTERS = ['All', 'Loans', 'Subsidy', 'Women', 'Artisans', 'Vendors'];

export default function Schemes() {
  const { state, toggleScheme, recommendations, setRecommendations } = useApp();
  const [loadError, setLoadError] = useState(null);
  const [q, setQ] = useState('');
  const [filter, setFilter] = useState('All');
  const [compare, setCompare] = useState([]);

  useEffect(() => {
    const { profile, requirement } = state;
    const controller = new AbortController();
    setRecommendations(null);
    setLoadError(null);
    fetchRecommendations({ profile, requirement }, { signal: controller.signal })
      .then((data) => setRecommendations(data.recommendations))
      .catch((error) => {
        if (error?.name !== 'AbortError') setLoadError(error);
      });
    return () => controller.abort();
  }, [state.profile, state.requirement]);

  const ranked = useMemo(() => recommendations || [], [recommendations]);
  const list = useMemo(() => {
    let l = ranked;
    if (q.trim()) {
      const t = q.toLowerCase();
      l = l.filter((s) => `${s.scheme_name || ''} ${(s.reasons || []).join(' ')} ${s.target_group_reason || ''}`.toLowerCase().includes(t));
    }
    if (filter !== 'All') l = l.filter((s) => `${s.scheme_name || ''} ${(s.reasons || []).join(' ')} ${s.target_group_reason || ''}`.toLowerCase().includes(filter.toLowerCase().replace('loans', 'loan')));
    return l;
  }, [ranked, q, filter]);

  const toggleCompare = (id) =>
    setCompare((c) => (c.includes(id) ? c.filter((x) => x !== id) : c.length < 3 ? [...c, id] : c));

  const cmpSchemes = ranked.filter((s) => compare.includes(s.scheme_id));

  const errorMessage = loadError instanceof RecommendationApiError
    ? `We couldn't load live recommendations (${loadError.kind}). Please try again.`
    : 'We couldn\'t load live recommendations. Please try again.';

  return (
    <PageWrap>
      <PageHeader
        eyebrow="Step 4 · Ranked for your profile"
        title="Schemes that may fit you."
        desc={`Based on ${state.profile.business} in ${state.profile.district} and a need of ${inr(state.requirement.loanAmount)}. Ranked by suitability — never by approval chances.`}
        step="recommend"
      >
        <button
          onClick={() => setCompare([])}
          className="btn-ghost !h-11"
          data-testid="compare-clear"
          style={{ display: compare.length ? 'inline-flex' : 'none' }}
        >
          <X size={15} /> Clear comparison
        </button>
      </PageHeader>

      <section className="container-x mt-10">
        <Reveal className="card-premium flex flex-col gap-4 p-4 sm:flex-row sm:items-center">
          <div className="relative flex-1">
            <Search size={17} className="absolute left-4 top-1/2 -translate-y-1/2 text-sage" />
            <input
              value={q}
              onChange={(e) => setQ(e.target.value)}
              placeholder="Search a scheme by name, purpose or ministry…"
              className="h-12 w-full rounded-full border border-border bg-cream pl-11 pr-4 text-sm outline-none transition-[border-color,box-shadow] focus:border-pine focus:ring-2 focus:ring-pine/15"
              data-testid="scheme-search-input"
            />
          </div>
          <div className="flex flex-wrap items-center gap-2">
            <SlidersHorizontal size={15} className="text-sage" />
            {FILTERS.map((f) => (
              <button
                key={f}
                onClick={() => setFilter(f)}
                data-testid={`filter-${f.toLowerCase()}`}
                className={`h-9 rounded-full border px-4 text-xs font-semibold transition-colors ${filter === f ? 'border-pine bg-pine text-white' : 'border-border text-sage hover:border-pine/40'}`}
              >
                {f}
              </button>
            ))}
          </div>
        </Reveal>

        <Reveal delay={0.08}>
          <div className="mt-5 flex items-center justify-between rounded-xl bg-sand px-4 py-3 text-xs text-pine">
            <span><strong>{recommendations ? list.length : '—'}</strong> schemes matched to your profile · match score = suitability, not approval probability</span>
            <Link to="/voice" className="hidden items-center gap-1.5 font-bold text-clay sm:flex" data-testid="schemes-voice-link"><Mic size={13} /> Prefer voice?</Link>
          </div>
        </Reveal>

        {recommendations === null && !loadError ? (
          <Reveal className="card-premium mt-8 p-12 text-center" data-testid="schemes-loading">
            <p className="font-display text-xl font-bold">Finding schemes for your profile…</p>
            <p className="mx-auto mt-2 max-w-md text-sm text-sage">Checking your information against the recommendation service.</p>
          </Reveal>
        ) : loadError ? (
          <Reveal className="card-premium mt-8 p-12 text-center" data-testid="schemes-error">
            <p className="font-display text-xl font-bold">Recommendations unavailable</p>
            <p className="mx-auto mt-2 max-w-md text-sm text-sage">{errorMessage}</p>
            <button className="btn-primary mt-6" onClick={() => window.location.reload()}>Try again</button>
          </Reveal>
        ) : list.length === 0 ? (
          <Reveal className="card-premium mt-8 p-12 text-center" data-testid="schemes-empty">
            <p className="font-display text-xl font-bold">We couldn't find a suitable match with that search.</p>
            <p className="mx-auto mt-2 max-w-md text-sm text-sage">Try a different keyword, or review your requirement so we can widen the search.</p>
            <Link to="/requirements" className="btn-primary mt-6" data-testid="schemes-review-req">Review my requirement</Link>
          </Reveal>
        ) : (
          <div className="mt-8 grid gap-6 md:grid-cols-2 xl:grid-cols-3">
            {list.map((s, i) => {
              const rank = ranked.findIndex((r) => r.scheme_id === s.scheme_id);
              return (
                <motion.div
                  key={s.scheme_id}
                  initial={{ opacity: 0, y: 26 }}
                  whileInView={{ opacity: 1, y: 0 }}
                  viewport={{ once: true, margin: '-40px' }}
                  transition={{ duration: 0.55, delay: Math.min(i * 0.06, 0.36), ease: [0.22, 1, 0.36, 1] }}
                  className="relative"
                >
                  <article className="card-premium group relative flex flex-col gap-5 p-6" data-testid={`scheme-card-${s.scheme_id}`}>
                    {rank === 0 && filter === 'All' && !q && <span className="absolute -top-3 left-6 rounded-full bg-pine px-3 py-1 text-[10px] font-bold uppercase tracking-[0.16em] text-white">Recommended for you</span>}
                    <div className="flex items-start justify-between gap-4">
                      <div>
                        <p className="eyebrow mb-1.5">Live recommendation</p>
                        <h3 className="font-display text-lg font-bold leading-snug">{s.scheme_name}</h3>
                        <p className="mt-0.5 text-xs text-sage">Scheme ID: {s.scheme_id}</p>
                      </div>
                      <div className="text-right"><p className="num font-display text-3xl font-bold text-pine">{s.match_score}</p><p className="text-[10px] text-sage">match score</p></div>
                    </div>
                    <p className="text-sm leading-relaxed text-sage">{s.reasons?.[0] || 'Recommendation details are available in the scheme explanation.'}</p>
                    <div className="grid grid-cols-2 gap-3 border-t border-border pt-4 text-xs">
                      <div><p className="font-semibold uppercase tracking-[0.14em] text-sage">Eligibility status</p><p className="mt-1 font-bold">{s.eligibility_status}</p></div>
                      <div><p className="font-semibold uppercase tracking-[0.14em] text-sage">Evidence coverage</p><p className="mt-1 font-bold">{s.evidence_coverage}%</p></div>
                    </div>
                    <div className="mt-auto flex flex-wrap items-center gap-2 pt-1">
                      <Link to={`/schemes/${s.scheme_id}`} className="btn-primary !h-10 !px-5 !text-[13px]">View details</Link>
                      <Link to={`/schemes/${s.scheme_id}/why`} className="btn-ghost !h-10 !px-5 !text-[13px]">Why this scheme?</Link>
                      <button onClick={() => toggleCompare(s.scheme_id)} data-testid={`compare-toggle-${s.scheme_id}`} className={`inline-flex h-10 items-center gap-1.5 rounded-full border px-4 text-[13px] font-semibold transition-colors ${compare.includes(s.scheme_id) ? 'border-clay bg-clay text-white' : 'border-border text-sage hover:border-clay/50 hover:text-clay'}`}><GitCompareArrows size={14} /> {compare.includes(s.scheme_id) ? 'Added' : 'Compare'}</button>
                    </div>
                  </article>
                  <button
                    onClick={() => toggleScheme(s.scheme_id)}
                    data-testid={`shortlist-${s.scheme_id}`}
                    className={`absolute right-4 top-4 rounded-full px-3 py-1 text-[10px] font-bold uppercase tracking-[0.1em] transition-colors ${state.selected.includes(s.scheme_id) ? 'bg-success text-white' : 'bg-muted text-sage hover:bg-pine hover:text-white'}`}
                    title="Shortlist for application"
                  >
                    {state.selected.includes(s.scheme_id) ? 'Shortlisted' : 'Shortlist'}
                  </button>
                </motion.div>
              );
            })}
          </div>
        )}

        <AnimatePresence>
          {cmpSchemes.length >= 2 && (
            <motion.div
              initial={{ opacity: 0, y: 30 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: 30 }}
              className="card-premium mt-12 overflow-hidden"
              data-testid="comparison-table"
            >
              <div className="border-b border-border bg-sand px-6 py-4">
                <h2 className="font-display text-lg font-bold">Side-by-side comparison</h2>
                <p className="text-xs text-sage">Only documented scheme parameters are compared.</p>
              </div>
              <div className="overflow-x-auto">
                <table className="w-full min-w-[720px] text-sm">
                  <thead>
                    <tr className="border-b border-border text-left">
                      <th className="p-4 text-xs font-semibold uppercase tracking-[0.12em] text-sage">Parameter</th>
                      {cmpSchemes.map((s) => <th key={s.scheme_id} className="p-4 font-display font-bold">{s.scheme_name}</th>)}
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-border">
                    {[
                      ['Match score', (s) => `${s.match_score}%`],
                      ['Ranking score', (s) => s.ranking_score],
                      ['Eligibility status', (s) => s.eligibility_status],
                      ['Relevance tier', (s) => s.relevance_tier],
                      ['Evidence coverage', (s) => `${s.evidence_coverage}%`],
                    ].map(([label, fn]) => (
                      <tr key={label}>
                        <td className="p-4 text-xs font-semibold uppercase tracking-[0.12em] text-sage">{label}</td>
                        {cmpSchemes.map((s) => <td key={s.scheme_id} className="num p-4 align-top text-[13px] font-medium">{fn(s)}</td>)}
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </motion.div>
          )}
        </AnimatePresence>

        <Reveal className="mt-12">
          <TrustNote>
            <strong>Recommendations are not approvals.</strong> A high match score means a scheme’s documented rules fit your
            profile well. The final decision always rests with the concerned authority or channel partner.
          </TrustNote>
        </Reveal>

        <div className="mt-8 overflow-hidden rounded-3xl">
          <div className="img-frame aspect-[21/6] hidden lg:block">
            <img src={IMG.womanDesk} alt="Woman entrepreneur comparing options at her desk" loading="lazy" />
          </div>
        </div>
      </section>
    </PageWrap>
  );
}
