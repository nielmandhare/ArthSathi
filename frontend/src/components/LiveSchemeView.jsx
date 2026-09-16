import { Link } from 'react-router-dom';

const Shell = ({ title, children }) => (
  <section className="container-x mt-10"><div className="card-premium p-6 sm:p-8"><h2 className="font-display text-xl font-bold">{title}</h2>{children}</div></section>
);

export function UnknownScheme() {
  return <Shell title="Scheme not found"><p className="mt-3 text-sm text-sage">This scheme ID is not present in the current recommendation response.</p><Link to="/schemes" className="btn-primary mt-6 inline-flex">Back to recommendations</Link></Shell>;
}

export function LiveDetail({ scheme }) {
  return <Shell title={scheme.scheme_name}><p className="mt-3 text-sm text-sage">Scheme ID: {scheme.scheme_id}</p><div className="mt-6 grid gap-4 sm:grid-cols-2"><Info label="Match score" value={scheme.match_score} /><Info label="Eligibility status" value={scheme.eligibility_status} /><Info label="Evidence coverage" value={`${scheme.evidence_coverage}%`} /><Info label="Ranking score" value={scheme.ranking_score} /></div><p className="mt-6 text-sm text-sage">{scheme.reasons?.[0] || 'No additional explanation was returned.'}</p><Actions id={scheme.scheme_id} /></Shell>;
}

export function LiveWhy({ scheme }) {
  return <Shell title={`Why ${scheme.scheme_name}?`}><p className="mt-3 text-sm text-sage">Recommendation evidence from the ML service. These signals are not approval decisions.</p><div className="mt-6 grid gap-4 sm:grid-cols-2"><Info label="Compatibility score" value={scheme.compatibility_score} /><Info label="Relevance score" value={scheme.relevance_score} /><Info label="Relevance tier" value={scheme.relevance_tier} /><Info label="Target-group match" value={scheme.target_group_match} /></div><Evidence title="Reasons" items={scheme.reasons} /><Evidence title="Verification required" items={scheme.verification_required} /><Evidence title="Target-group reason" items={scheme.target_group_reason ? [scheme.target_group_reason] : []} /><Actions id={scheme.scheme_id} /></Shell>;
}

export function LiveEligibility({ scheme }) {
  return <Shell title={`Eligibility information for ${scheme.scheme_name}`}><div className="mt-4 rounded-xl bg-sand p-4 text-sm"><strong>{scheme.eligibility_status}</strong><p className="mt-1 text-sage">This status reflects available evidence only and is not final government eligibility.</p></div><Evidence title="Unmet criteria" items={scheme.unmet_criteria} /><Evidence title="Verification required" items={scheme.verification_required} /><Actions id={scheme.scheme_id} /></Shell>;
}

export function LiveDocuments({ scheme }) {
  return <Shell title={`Documents for ${scheme.scheme_name}`}><p className="mt-3 text-sm text-sage">Document requirements are not provided by the recommendation response.</p><p className="mt-3 text-sm text-sage">Verify required documents with the concerned authority or channel partner.</p><Actions id={scheme.scheme_id} /></Shell>;
}

export function LiveCalculator({ scheme }) {
  return <Shell title={`Financial information for ${scheme.scheme_name}`}><p className="mt-3 text-sm text-sage">Interest rate, tenure, repayment terms, and other calculator metadata are not provided by the recommendation response.</p><p className="mt-3 text-sm text-sage">No unsupported EMI estimate is shown.</p><Actions id={scheme.scheme_id} /></Shell>;
}

function Info({ label, value }) { return <div className="rounded-xl bg-sand p-4"><p className="text-[10px] font-semibold uppercase tracking-[0.14em] text-sage">{label}</p><p className="mt-1 font-bold">{value ?? 'Not provided'}</p></div>; }
function Evidence({ title, items }) { return <div className="mt-6"><h3 className="font-display text-lg font-bold">{title}</h3>{items?.length ? <ul className="mt-2 list-disc space-y-1 pl-5 text-sm text-sage">{items.map((item, i) => <li key={i}>{item}</li>)}</ul> : <p className="mt-2 text-sm text-sage">No information provided.</p>}</div>; }
function Actions({ id }) { return <div className="mt-8 flex flex-wrap gap-3"><Link to={`/schemes/${id}`} className="btn-primary">Overview</Link><Link to="/schemes" className="btn-ghost">Back to recommendations</Link></div>; }
