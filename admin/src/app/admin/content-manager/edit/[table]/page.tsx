import { Suspense } from 'react'
import TableEditor from '@/components/content/TableEditor'

export default function EditTablePage({ params }: { params: { table: string } }) {
  return (
    <Suspense fallback={null}>
      <TableEditor table={params.table} />
    </Suspense>
  )
}
