import { HashRouter, Routes, Route } from 'react-router-dom'
import Layout from './components/Layout'
import Dashboard from './pages/Dashboard'
import PersonenPage from './pages/PersonenPage'
import InstellingenPage from './pages/InstellingenPage'
import ObjectenPage from './pages/ObjectenPage'
import ContractenPage from './pages/ContractenPage'
import SchadeclaimsPage from './pages/SchadeclaimsPage'
import RapportenPage from './pages/RapportenPage'
import BeheerPage from './pages/BeheerPage'

export default function App() {
  return (
    <HashRouter>
      <Routes>
        <Route element={<Layout />}>
          <Route path="/" element={<Dashboard />} />
          <Route path="/personen" element={<PersonenPage />} />
          <Route path="/instellingen" element={<InstellingenPage />} />
          <Route path="/objecten" element={<ObjectenPage />} />
          <Route path="/contracten" element={<ContractenPage />} />
          <Route path="/schadeclaims" element={<SchadeclaimsPage />} />
          <Route path="/rapporten" element={<RapportenPage />} />
          <Route path="/beheer" element={<BeheerPage />} />
        </Route>
      </Routes>
    </HashRouter>
  )
}
